app.controller('modListPluginsController', function($scope, $q, $timeout, categoryService, modListService, columnsFactory, actionsFactory, colorsFactory, listUtils, sortUtils, requirementUtils) {
    // initialize variables
    $scope.showDetailsModal = false;
    $scope.detailsItem = {};
    $scope.columns = columnsFactory.modListPluginColumns();
    $scope.columnGroups = columnsFactory.modListPluginColumnGroups();
    $scope.actions = actionsFactory.modListPluginActions();

    $scope.toggleDetailsModal = function(visible, item) {
        $scope.$emit('toggleModal', visible);
        $scope.detailsItem = item;
        $scope.showDetailsModal = visible;
    };

    $scope.toggleManagePluginsModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showManagePluginsModal = visible;
    };

    $scope.searchPluginStore = function(str) {
        var action = $q.defer();
        var matchingPlugins = $scope.plugins_store.filter(function(plugin) {
            return plugin.filename.toLowerCase().includes(str);
        });
        action.resolve(matchingPlugins);
        return action.promise;
    };

    $scope.buildPluginsModel = function() {
        var plugins = $scope.mod_list.plugins.concat($scope.mod_list.custom_plugins);
        $scope.model.plugins = [];
        $scope.mod_list.groups.forEach(function(group) {
            if (group.tab !== 'plugins') {
                return;
            }
            $scope.model.plugins.push(group);
            group.children = plugins.filter(function(plugin) {
                return plugin.group_id == group.id;
            });
        });
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
                $scope.model.plugins.splice(insertIndex, 0, angular.copy(plugin));
            }
        });
    };

    $scope.destroyModRemovedPlugins = function() {
        if (!$scope.removedModIds.length) return;
        var removeIfModRemoved = function(item) {
            if (!item._destroy && $scope.removedModIds.indexOf(item.mod.id) > -1) {
                $scope.removePlugin(item);
            }
        };
        $scope.model.plugins.forEach(function(item) {
            if (item.children) {
                item.children.forEach(removeIfModRemoved)
            } else {
                removeIfModRemoved(item);
            }
        });
        $scope.plugins_store.forEach(function(plugin) {
            if ($scope.removedModIds.indexOf(plugin.mod_id) > -1) {
                plugin._destroy = true;
            }
        });
    };

    $scope.retrievePlugins = function() {
        modListService.retrieveModListPlugins($scope.mod_list.id).then(function(data) {
            categoryService.associateCategories($scope.categories, data.plugins);
            $scope.required.plugins = data.required_plugins;
            $scope.notes.plugin_compatibility = data.compatibility_notes;
            $scope.notes.load_order = data.load_order_notes;
            $scope.mod_list.plugins = data.plugins;
            $scope.mod_list.custom_plugins = data.custom_plugins;
            $scope.plugins_store = data.plugins_store;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.plugins = angular.copy($scope.mod_list.plugins);
            $scope.originalModList.custom_plugins = angular.copy($scope.mod_list.custom_plugins);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.associateIgnore($scope.notes.plugin_compatibility, 'CompatibilityNote');
            $scope.associateIgnore($scope.notes.load_order, 'LoadOrderNote');
            $scope.buildPluginsModel();
            $timeout(function() {
                $scope.destroyModRemovedPlugins();
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
            index: listUtils.getNextIndex($scope.model.plugins)
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

    $scope.togglePlugin = function(pluginItem) {
        if (pluginItem.active) {
            $scope.addPlugin(pluginItem.id);
        } else {
            var foundPlugin = $scope.findPlugin(pluginItem.id, true);
            if (foundPlugin) $scope.removePlugin(foundPlugin);
        }
    };

    // LOAD ORDER SORTING
    $scope.startSortLoadOrder = function() {
        // Display activity modal
        $scope.startActivity('Sorting Load Order');
        $scope.setActivityMessage('Preparing mod list for sorting');

        // Dissassociate plugins, destroy original groups, and unmark as merged
        sortUtils.prepareToSort($scope.mod_list, 'plugins');

        // Save changes and call sortLoadOrder if successful
        $scope.saveChanges(true).then(function() {
            $scope.sortLoadOrder();
        }, function() {
            $scope.$emit('customMessage', { type: 'error', text: "Failed to sort load order.  Couldn't save mod list."});
            $scope.setActivityMessage('Failed to prepare mod list for sorting');
            $scope.completeActivity();
        });
    };

    $scope.sortLoadOrder = function() {
        // STEP 1: Build groups for categories
        $scope.setActivityMessage('Building category groups');
        var groups = sortUtils.buildGroups($scope.mod_list, 'plugins');

        // STEP 2: Merge category groups with less than 5 members into super category groups
        sortUtils.combineGroups($scope.mod_list, 'plugins', groups, $scope.categories);

        // STEP 3: Sort groups and sort plugins in groups by override count
        $scope.setActivityMessage('Sorting groups and plugins');
        sortUtils.sortGroupsByPriority(groups);
        sortUtils.sortItems(groups, 'plugin', 'overrides_count');
        listUtils.updateItems(groups, 0);

        // STEP 4: Save the new groups and associate plugins with groups
        $scope.setActivityMessage('Saving groups');
        var groupPromises = sortUtils.saveGroups(groups, $scope.model, 'plugins', $scope.mod_list, $scope.originalModList);

        $q.all(groupPromises).then(function() {
            // STEP 5: Sort plugins per load order notes and master dependencies
            $scope.setActivityMessage('Handling load order notes and master dependencies');
            $scope.$broadcast('resolveAllLoadOrder');

            // STEP 6: Update indexes and save changes
            $timeout(function() {
                $scope.saveChanges().then(function() {
                    $scope.setActivityMessage('Finalizing changes');
                    $scope.setActivityMessage('All done!');
                    $scope.completeActivity();
                }, function() {
                    $scope.setActivityMessage('Failed to save changes, please save manually.');
                    $scope.completeActivity();
                });
            });
        });
    };

    // event triggers
    $scope.$on('removeItem', function(event, modListPlugin) {
        $scope.removePlugin(modListPlugin);
    });
    $scope.$on('modRemoved', function(event, modId) {
        var removedIfModMatches = function(item) {
            if (item.mod.id == modId) {
                $scope.removePlugin(item);
            }
        };
        $scope.model.plugins.forEach(function(item) {
            if (item.children) {
                item.children.forEach(removedIfModMatches)
            } else {
                removedIfModMatches(item);
            }
        });
        $scope.plugins_store.forEach(function(plugin) {
            if (plugin.mod_id == modId) {
                plugin._destroy = true;
            }
        });
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