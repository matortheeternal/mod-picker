app.controller('modListPluginsController', function($scope, $q, modListService, columnsFactory, actionsFactory, listUtils) {
    // initialize variables
    $scope.columns = columnsFactory.modListPluginColumns();
    $scope.columnGroups = columnsFactory.modListPluginColumnGroups();
    $scope.actions = actionsFactory.modListPluginActions();

    // functions
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
        $scope.mod_list.plugins.forEach(function(plugin) {
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
        $scope.retrieving.plugins = true;
        modListService.retrieveModListPlugins($scope.mod_list.id).then(function(data) {
            $scope.required.plugins = data.required_plugins;
            $scope.notes.plugin_compatibility = data.compatibility_notes;
            $scope.notes.load_order = data.load_order_notes;
            $scope.mod_list.plugins = data.plugins;
            $scope.plugin_store = data.plugin_store;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.plugins = angular.copy($scope.mod_list.plugins);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.buildPluginsModel();
            $scope.$broadcast('initializeModules');
            $scope.retrieving.plugins = false;
        }, function(response) {
            $scope.errors.plugins = response;
        });
    };

    // retrieve plugins if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.plugins && !$scope.retrieving.plugins) {
        $scope.retrievePlugins();
    }
    
    // plugin handling
    $scope.recoverPlugin = function(modListPlugin) {
        // if plugin is already present on the user's mod list but has been
        // removed, add it back
        if (modListPlugin._destroy) {
            delete modListPlugin._destroy;
            $scope.mod_list.plugins_count += 1;
            $scope.updateTabs();

            // upudate modules
            $scope.$broadcast('pluginRecovered', modListPlugin.plugin.id);
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
            index: $scope.mod_list.plugins.length
        };

        modListService.newModListPlugin(mod_list_plugin).then(function(data) {
            // push plugin onto view
            $scope.mod_list.plugins.push(data.mod_list_plugin);
            $scope.model.plugins.push(data.mod_list_plugin);
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
        $scope.$broadcast('pluginRemoved', modListPlugin.plugin.id);
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
});