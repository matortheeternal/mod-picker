app.controller('modListPluginsController', function($scope, $q, $timeout, modListService, columnsFactory, actionsFactory, listUtils) {
    // initialize variables
    $scope.showDetailsModal = false;
    $scope.detailsItem = {};
    $scope.columns = columnsFactory.modListPluginColumns();
    $scope.columnGroups = columnsFactory.modListPluginColumnGroups();
    $scope.actions = actionsFactory.modListPluginActions();

    $scope.toggleDetailsModal = function(visible, item) {
        $scope.$emit('toggleModal', visible);
        $scope.showDetailsModal = visible;
        $scope.detailsItem = item;
    };

    $scope.searchPluginStore = function(str) {
        var action = $q.defer();
        var matchingPlugins = $scope.plugin_store.filter(function(plugin) {
            return plugin.filename.toLowerCase().includes(str);
        });
        action.resolve(matchingPlugins);
        return action.promise;
    };

    $scope.buildPluginsModel = function() {
        $scope.model.plugins = [];
        $scope.mod_list.groups.forEach(function(group) {
            if (group.tab !== 'plugins') {
                return;
            }
            $scope.model.plugins.push(group);
            group.children = $scope.mod_list.plugins.filter(function(plugin) {
                return plugin.group_id == group.id;
            });
        });
        var plugins = $scope.mod_list.plugins.concat($scope.mod_list.custom_plugins);
        plugins.forEach(function(plugin) {
            if (!plugin.group_id) {
                var insertIndex = $scope.model.plugins.findIndex(function(item) {
                    return item.index > plugin.index;
                });
                if (insertIndex == -1) {
                    insertIndex = $scope.model.plugins.length;
                } else if (plugin.merged) {
                    insertIndex--;
                }
                $scope.model.plugins.splice(insertIndex, 0, plugin);
            }
        });
    };

    $scope.retrievePlugins = function() {
        modListService.retrieveModListPlugins($scope.mod_list.id).then(function(data) {
            $scope.required.plugins = data.required_plugins;
            $scope.notes.plugin_compatibility = data.compatibility_notes;
            $scope.notes.load_order = data.load_order_notes;
            $scope.mod_list.plugins = data.plugins;
            $scope.mod_list.custom_plugins = data.custom_plugins;
            $scope.plugin_store = data.plugin_store;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.plugins = angular.copy($scope.mod_list.plugins);
            $scope.originalModList.custom_plugins = angular.copy($scope.mod_list.custom_plugins);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.associateIgnore($scope.notes.plugin_compatibility, 'CompatibilityNote');
            $scope.associateIgnore($scope.notes.load_order, 'LoadOrderNote');
            $scope.buildPluginsModel();
            $timeout(function() {
                $scope.$broadcast('initializeModules');
            }, 100);
            $scope.pluginsReady = true;
        }, function(response) {
            $scope.errors.plugins = response;
        });
    };

    // retrieve plugins when the state is first loaded
    $scope.retrievePlugins();
    
    // plugin handling
    $scope.recoverPlugin = function(modListPlugin) {
        // if plugin is already present on the user's mod list but has been
        // removed, add it back
        if (modListPlugin._destroy) {
            delete modListPlugin._destroy;
            $scope.mod_list.plugins_count += 1;
            $scope.updateTabs();

            // upudate modules
            $scope.$broadcast('pluginRecovered', !!modListPlugin.plugin && modListPlugin.plugin.id);
            $scope.$broadcast('updateItems');

            // success message
            $scope.$emit('successMessage', 'Added plugin ' + modListPlugin.plugin.filename+ ' successfully.');
        }
        // else inform the user that the plugin is already on their mod list
        else {
            var params = {type: 'error', text: 'Failed to add plugin ' + modListPlugin.plugin.filename + ', the plugin has already been added to this mod list.'};
            $scope.$emit('customMessage', params);
        }
    };

    $scope.addNewPlugin = function(pluginId) {
        var mod_list_plugin = {
            mod_list_id: $scope.mod_list.id,
            plugin_id: pluginId,
            index: $scope.getNextIndex($scope.model.plugins)
        };

        modListService.newModListPlugin(mod_list_plugin).then(function(data) {
            // push plugin onto view
            var modListPlugin = data.mod_list_plugin;
            $scope.mod_list.plugins.push(modListPlugin);
            $scope.model.plugins.push(modListPlugin);
            $scope.originalModList.plugins.push(angular.copy(modListPlugin));
            $scope.mod_list.plugins_count += 1;
            $scope.updateTabs();

            // update modules
            $scope.$broadcast('pluginAdded', data);
            $scope.$broadcast('updateItems');

            // success message
            var filename = data.mod_list_plugin.plugin.filename;
            $scope.$emit('successMessage', 'Added plugin ' + filename + ' successfully.');
        }, function(response) {
            var params = {label: 'Error adding plugin', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addCustomPlugin = function(compatibilityNoteId) {
        var custom_plugin = {
            mod_list_id: $scope.mod_list.id,
            index: listUtils.getNextIndex($scope.model.plugins),
            filename: 'CustomPlugin.esp'
        };

        if (compatibilityNoteId) {
            var foundCustomPlugin = $scope.findCustomPlugin(compatibilityNoteId);
            if (foundCustomPlugin) {
                foundCustomPlugin._destroy = false;
                $scope.$broadcast('customPluginAdded');
                return;
            }
            custom_plugin.filename = 'CustomPatch'+compatibilityNoteId+'.esp';
            custom_plugin.compatibility_note_id = compatibilityNoteId;
        }

        modListService.newModListCustomPlugin(custom_plugin).then(function(data) {
            // push plugin onto view
            var modListCustomPlugin = data.mod_list_custom_plugin;
            modListService.associateCompatibilityNote(modListCustomPlugin, $scope.notes.plugin_compatibility);
            $scope.mod_list.custom_plugins.push(modListCustomPlugin);
            $scope.model.plugins.push(modListCustomPlugin);
            $scope.originalModList.custom_plugins.push(angular.copy(modListCustomPlugin));
            $scope.mod_list.plugins_count += 1;
            $scope.updateTabs();

            // update modules
            $scope.$broadcast('customPluginAdded');
            $scope.$broadcast('updateItems');

            // open plugin details for custom plugin
            $scope.toggleDetailsModal(true, modListCustomPlugin);
        }, function(response) {
            var params = {label: 'Error adding custom plugin', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addPlugin = function(pluginId) {
        // return if we don't have a mod to add
        if (!pluginId) {
            return;
        }

        // see if the plugin is already present on the user's plugin list
        var existingPlugin = $scope.findPlugin(pluginId);
        if (existingPlugin) {
            $scope.recoverPlugin(existingPlugin);
        } else {
            $scope.addNewPlugin(pluginId);
        }

        if ($scope.add.plugin.id) {
            $scope.add.plugin.id = null;
            $scope.add.plugin.name = "";
        }
    };

    $scope.removePlugin = function(modListPlugin) {
        modListPlugin._destroy = true;
        $scope.mod_list.plugins_count -= 1;
        $scope.updateTabs();

        // update modules
        $scope.$broadcast('pluginRemoved', !!modListPlugin.plugin && modListPlugin.plugin.id);
        $scope.$broadcast('updateItems');
    };

    $scope.toggleLoadOrder = function() {
        $scope.showLoadOrder = !$scope.showLoadOrder;
        $scope.columns[0].visibility = !$scope.showLoadOrder;
        $scope.columns[1].visibility = $scope.showLoadOrder;
    };

    // event triggers
    $scope.$on('removeItem', function(event, modListPlugin) {
        $scope.removePlugin(modListPlugin);
    });
    $scope.$on('rebuildModels', $scope.buildPluginsModel);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.mod_list.plugins);
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.mod_list.plugins);
    });
    $scope.$on('itemMoved', function() {
        $scope.$broadcast('pluginMoved');
    });
    $scope.$on('toggleDetailsModal', function(event, options) {
        $scope.toggleDetailsModal(options.visible, options.item);
    });
});