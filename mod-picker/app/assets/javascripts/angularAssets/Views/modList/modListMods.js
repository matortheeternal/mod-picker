app.controller('modListModsController', function($scope, $rootScope, $timeout, modListService, modService, listUtils, columnsFactory, actionsFactory) {
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
        $scope.mod_list.groups.forEach(function(group) {
            if (group.tab !== 'mods') {
                return;
            }
            $scope.model.mods.push(group);
            group.children = $scope.mod_list.mods.filter(function(mod) {
                return mod.group_id == group.id;
            });
        });
        var mods = $scope.mod_list.mods.concat($scope.mod_list.custom_mods);
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

    $scope.retrieveMods = function() {
        modListService.retrieveModListMods($scope.mod_list.id).then(function(data) {
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

            // upudate modules
            $rootScope.$broadcast('modRecovered', !!modListMod.mod && modListMod.mod.id);
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
            mod_id: modId,
            index: listUtils.getNextIndex($scope.model.mods)
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
        $scope.$broadcast('updateItems');
    };

    // event triggers
    $scope.$on('removeMod', function(event, modId) {
        var foundMod = $scope.findMod(modId);
        if (foundMod) {
            $scope.removeMod(foundMod);
        }
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
    });
    $scope.$on('itemMoved', function() {
        $scope.$broadcast('modMoved');
    });
    $scope.$on('toggleDetailsModal', function(event, options) {
        $scope.toggleDetailsModal(options.visible, options.item);
    });
});