app.controller('modListModsController', function($scope, $rootScope, $timeout, $q, categories, categoryService, modListService, modService, columnsFactory, actionsFactory, listUtils, sortUtils) {
    // initialize variables
    $scope.showDetailsModal = false;
    $scope.detailsItem = {};
    $scope.columns = columnsFactory.modListModColumns();
    $scope.columnGroups = columnsFactory.modListModColumnGroups();
    $scope.actions = actionsFactory.modListModActions();
    $scope.searchMods = modService.searchModListMods;

    $scope.toggleDetailsModal = function(visible, item) {
        $scope.$emit('toggleModal', visible);
        $scope.showDetailsModal = visible;
        $scope.detailsItem = item;
    };

    $scope.buildModsModel = function() {
        $scope.model.mods = [];
        var mods = $scope.mod_list.mods.concat($scope.mod_list.custom_mods);

        // push groups onto view model and children mods into groups
        $scope.mod_list.groups.forEach(function(group) {
            if (group.tab !== 'mods') {
                return;
            }
            $scope.model.mods.push(group);
            group.children = mods.filter(function(mod) {
                return mod.group_id == group.id;
            });
        });

        // push mods that aren't in any group onto view model
        mods.forEach(function(mod) {
            if (!mod.group_id) {
                var insertIndex = $scope.model.mods.findIndex(function(item) {
                    return item.index > mod.index;
                });
                if (insertIndex == -1) {
                    insertIndex = $scope.model.mods.length;
                }
                $scope.model.mods.splice(insertIndex, 0, angular.copy(mod));
            }
        });
    };

    $scope.associateModOptionPluginMods = function(modListMods) {
        modListMods.forEach(function(modListMod) {
            modListMod.mod.mod_options.forEach(function(modOption) {
                modOption.plugins.forEach(function(plugin) {
                    plugin.mod = {
                        id: modListMod.mod.id,
                        name: modListMod.mod.name
                    }
                });
            });
        });
    };

    $scope.retrieveMods = function() {
        modListService.retrieveModListMods($scope.mod_list.id).then(function(data) {
            categoryService.associateCategories(categories, data.mods);
            $scope.associateModOptionPluginMods(data.mods);
            $scope.required.mods = data.required_mods;
            $scope.notes.compatibility = data.compatibility_notes;
            $scope.notes.install_order = data.install_order_notes;
            $scope.mod_list.mods = data.mods;
            $scope.mod_list.custom_mods = data.custom_mods;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.mods = angular.copy($scope.mod_list.mods);
            $scope.originalModList.custom_mods = angular.copy($scope.mod_list.custom_mods);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.associateIgnore($scope.notes.compatibility, 'CompatibilityNote');
            $scope.associateIgnore($scope.notes.install_order, 'InstallOrderNote');
            $scope.buildModsModel();
            $timeout(function() {
                $scope.$broadcast('initializeModules');
            }, 100);
            $scope.modsReady = true;
        }, function(response) {
            $scope.errors.mods = response;
        });
    };

    // retrieve mods when the state is first loaded
    $scope.retrieveMods();

    $scope.recoverMod = function(modListMod) {
        // if mod is already present on the user's mod list but has been
        // removed, add it back
        if (modListMod._destroy) {
            delete modListMod._destroy;
            $scope.mod_list.mods_count += 1;
            $scope.updateTabs();

            // update modules
            $rootScope.$broadcast('modRecovered', !!modListMod.mod && modListMod.mod.id);
            modListMod.mod && modListMod.mod_list_mod_options.forEach(function(option) {
                $rootScope.$broadcast('modOptionAdded', option.mod_option_id);
            });
            $scope.$broadcast('updateItems');

            // success message
            $scope.$emit('successMessage', 'Added mod ' + modListMod.mod.name + ' successfully.');
        }
        // else inform the user that the mod is already on their mod list
        else {
            var params = {type: 'error', text: 'Failed to add mod ' + modListMod.mod.name + ', the mod has already been added to this mod list.'};
            $scope.$emit('customMessage', params);
        }
    };

    $scope.addNewMod = function(modId) {
        var mod_list_mod = {
            mod_list_id: $scope.mod_list.id,
            mod_id: modId
        };

        modListService.newModListMod(mod_list_mod).then(function(data) {
            // push mod onto view
            var modListMod = data.mod_list_mod;
            $scope.mod_list.mods.push(modListMod);
            $scope.model.mods.push(modListMod);
            $scope.originalModList.mods.push(angular.copy(modListMod));
            $scope.mod_list.mods_count += 1;
            $scope.updateTabs();

            // update modules
            $rootScope.$broadcast('modAdded', data);
            $scope.$broadcast('updateItems');

            // set default mod options
            modListMod.mod.mod_options.forEach(function(option) {
                if (option.default) {
                    option.active = true;
                    modListMod.mod_list_mod_options.push({
                        mod_option_id: option.id
                    });
                    $rootScope.$broadcast('modOptionAdded', option.id);
                }
            });

            // success message
            $scope.$emit('successMessage', 'Added mod ' + modListMod.mod.name + ' successfully.');
        }, function(response) {
            var params = {label: 'Error adding mod', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addCustomMod = function() {
        var custom_mod = {
            mod_list_id: $scope.mod_list.id,
            index: listUtils.getNextIndex($scope.model.mods),
            name: 'Custom Mod'
        };

        modListService.newModListCustomMod(custom_mod).then(function(data) {
            // push plugin onto view
            var modListCustomMod = data.mod_list_custom_mod;
            $scope.mod_list.custom_mods.push(modListCustomMod);
            $scope.model.mods.push(modListCustomMod);
            $scope.originalModList.custom_mods.push(angular.copy(modListCustomMod));
            $scope.mod_list.mods_count += 1;
            $scope.updateTabs();

            // update modules
            $scope.$broadcast('customModAdded');
            $scope.$broadcast('updateItems');

            // open plugin details for custom plugin
            $scope.toggleDetailsModal(true, modListCustomMod);
        }, function(response) {
            var params = {label: 'Error adding custom mod', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addMod = function(modId) {
        // return if we don't have a mod to add
        if (!modId) {
            return;
        }

        // see if the mod is already present on the user's mod list
        var existingMod = $scope.findMod(modId);
        if (existingMod) {
            $scope.recoverMod(existingMod);
        } else {
            $scope.addNewMod(modId);
        }

        if ($scope.add.mod.id) {
            $scope.add.mod.id = null;
            $scope.add.mod.name = "";
        }
    };

    $scope.removeMod = function(modListMod) {
        modListMod._destroy = true;
        $scope.mod_list.mods_count -= 1;
        $scope.updateTabs();

        // update modules
        $rootScope.$broadcast('modRemoved', !!modListMod.mod && modListMod.mod.id);
        modListMod.mod && modListMod.mod.mod_options.forEach(function(option) {
            if (option.active) $rootScope.$broadcast('modOptionRemoved', option.id);
        });
        $scope.$broadcast('updateItems');
    };

    // INSTALL ORDER SORTING
    $scope.startSortInstallOrder = function() {
        // Display activity modal
        $scope.startActivity('Sorting Install Order');
        $scope.setActivityMessage('Preparing mod list for sorting');

        // Dissassociate mods, destroy original groups
        sortUtils.setSortTarget($scope.mod_list, 'mods');
        sortUtils.prepareToSort();

        // Save changes and call sortInstallOrder if successful
        $scope.saveChanges(true).then(function() {
            $scope.sortInstallOrder();
        }, function() {
            $scope.$emit('customMessage', { type: 'error', text: "Failed to sort install order.  Couldn't save mod list."});
            $scope.setActivityMessage('Failed to prepare mod list for sorting');
            $scope.completeActivity();
        });
    };

    $scope.sortInstallOrder = function() {
        // STEP 1: Build groups for categories
        $scope.setActivityMessage('Building category groups');
        var groups = sortUtils.buildGroups();

        // STEP 2: Merge category groups with less than 5 members into super category groups
        sortUtils.combineGroups(groups, $scope.categories);

        // STEP 3: Sort groups and sort mods in groups by asset file count
        $scope.setActivityMessage('Sorting groups and mods');
        sortUtils.sortGroupsByPriority(groups);
        sortUtils.sortItems(groups, 'mod', 'asset_files_count');
        listUtils.updateItems(groups, 1);

        // STEP 4: Save the new groups and associate mods with groups
        $scope.setActivityMessage('Saving groups');
        sortUtils.setSaveTarget($scope.model, $scope.originalModList);
        var groupPromises = sortUtils.saveGroups(groups);

        $q.all(groupPromises).then(function() {
            // STEP 5: Sort mods per install order notes
            sortUtils.sortModel();
            $scope.setActivityMessage('Handling install order notes');
            $scope.$broadcast('resolveAllInstallOrder');

            // STEP 6: Save changes
            $timeout(function() {
                $scope.setActivityMessage('Finalizing changes');
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
    $scope.$on('removeMod', function(event, modId) {
        var foundMod = $scope.findMod(modId);
        if (foundMod) {
            $scope.removeMod(foundMod);
        }
    });
    $scope.$on('modRemoved', function(event, modId) {
        $scope.removedModIds.push(modId);
    });
    $scope.$on('modRecovered', function(event, modId) {
        var index = $scope.removedModIds.indexOf(modId);
        if (index > -1) $scope.removedModIds.splice(index, 1);
    });
    $scope.$on('removeItem', function(event, modListMod) {
        $scope.removeMod(modListMod);
    });
    $scope.$on('rebuildModels', $scope.buildModsModel);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.mod_list.mods);
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.mod_list.mods);
        $scope.removedModIds = [];
    });
    $scope.$on('itemMoved', function() {
        $scope.$broadcast('modMoved');
    });
    $scope.$on('toggleDetailsModal', function(event, options) {
        $scope.toggleDetailsModal(options.visible, options.item);
    });
});