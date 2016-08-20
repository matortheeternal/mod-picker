app.controller('modListPluginsController', function($scope, $q, $timeout, categoryService, modListService, columnsFactory, actionsFactory, colorsFactory, listUtils, sortUtils) {
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
        sortUtils.prepareToSortPlugins($scope.mod_list);

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
        var groups = sortUtils.buildPluginGroups($scope.mod_list);

        // STEP 2: Merge category groups with less than 5 members into super category groups
        sortUtils.combinePluginGroups($scope.mod_list, groups, $scope.categories);

        // STEP 3: Sort groups and sort plugins in groups by override count
        $scope.setActivityMessage('Sorting groups and plugins');
        sortUtils.sortGroupsByPriority(groups);
        sortUtils.sortPluginsByOverrides(groups);
        sortUtils.updateIndexes(groups);

        /* NOW ORPHANING PLUGINS OUTSIDE OF GROUPS IF NECESSARY */
        // STEP 4: Sort plugins per load order notes
        $scope.setActivityMessage('Handling load order notes');
        sortUtils.handleLoadOrderNotes(groups, $scope.notes.load_order);

        // STEP 5: Sort plugins per master dependencies
        $scope.setActivityMessage('Handling master dependencies');
        sortUtils.handleMasterDependencies(groups, $scope.required.plugins);

        // STEP 6: Save the new groups and associate plugins with groups
        $scope.setActivityMessage('Saving groups');
        $scope.model.plugins = [];
        var groupPromises = [];
        groups.forEach(function(group) {
            // skip empty groups
            if (!group.children.length) return;

            // prepare promise for tracking purposes
            var action = $q.defer();
            var groupItem = {
                mod_list_id: group.mod_list_id,
                index: group.index,
                tab: group.tab,
                color: group.color,
                name: group.name,
                description: group.description
            };

            // tell the server to create the new mod list group
            modListService.newModListGroup(groupItem).then(function(data) {
                var newGroup = data;
                newGroup.children = [];

                // associate children with the new group object
                group.children.forEach(function(child) {
                    child.group_id = data.id;
                    newGroup.children.push(child);
                });

                // push the new group object onto the view model
                $scope.mod_list.groups.push(newGroup);
                $scope.originalModList.groups.push(angular.copy(newGroup));
                $scope.model.plugins.push(newGroup);
                action.resolve(newGroup);
            }, function(response) {
                action.reject(response);
            });

            // push the promise onto the groupPromises array
            groupPromises.push(action.promise);
        });

        // STEP 7: Update indexes and save changes
        $q.all(groupPromises).then(function() {
            $scope.setActivityMessage('Finalizing changes');
            $scope.$broadcast('updateItems');
            $timeout(function() {
                $scope.saveChanges().then(function() {
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