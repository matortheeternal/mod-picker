app.controller('modListModsController', function($scope, modListService, modService) {
    $scope.searchMods = modService.searchModsNoTools;

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
        $scope.mod_list.mods.forEach(function(mod) {
            if (!mod.group_id) {
                var insertIndex = $scope.model.mods.findIndex(function(item) {
                    return item.index > mod.index;
                });
                if (insertIndex == -1) {
                    insertIndex = $scope.model.mods.length;
                }
                $scope.model.mods.splice(insertIndex, 0, mod);
            }
        });
    };

    $scope.retrieveMods = function() {
        $scope.retrieving.mods = true;
        modListService.retrieveModListMods($scope.mod_list.id).then(function(data) {
            $scope.required.mods = data.required_mods;
            $scope.notes.compatibility = data.compatibility_notes;
            $scope.notes.install_order = data.install_order_notes;
            $scope.mod_list.mods = data.mods;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.mods = angular.copy($scope.mod_list.mods);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.buildModsModel();
            $scope.buildMissingMods();
            $scope.buildUnresolvedCompatibility();
            $scope.buildUnresolvedInstallOrder();
            $scope.retrieving.mods = false;
        }, function(response) {
            $scope.errors.mods = response;
        });
    };

    // retrieve mods if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.mods && !$scope.retrieving.mods) {
        $scope.retrieveMods();
    }

    $scope.reAddMod = function(modListMod) {
        // if mod is already present on the user's mod list but has been
        // removed, add it back
        if (modListMod._destroy) {
            delete modListMod._destroy;
            $scope.mod_list.mods_count += 1;
            $scope.reAddRequirements(modListMod.mod.id);
            $scope.reAddNotes(modListMod.mod.id);
            $scope.buildMissingMods();
            $scope.buildUnresolvedCompatibility();
            $scope.buildUnresolvedInstallOrder();
            $scope.updateTabs();
            $scope.$broadcast('updateItems');
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
            index: $scope.mod_list.mods.length
        };

        modListService.newModListMod(mod_list_mod).then(function(data) {
            // push mod onto view
            $scope.mod_list.mods.push(data.mod_list_mod);
            $scope.model.mods.push(data.mod_list_mod);
            $scope.mod_list.mods_count += 1;
            $scope.updateTabs();

            // handle requirements
            Array.prototype.unite($scope.required.tools, data.required_tools);
            Array.prototype.unite($scope.required.mods, data.required_mods);
            $scope.$emit('rebuildMissing');

            // handle notes
            Array.prototype.unite($scope.notes.compatibility, data.compatibility_notes);
            Array.prototype.unite($scope.notes.install_order, data.install_order_notes);
            $scope.$emit('rebuildUnresolved');

            // success message
            $scope.$broadcast('updateItems');
            $scope.$emit('successMessage', 'Added mod ' + data.mod_list_mod.mod.name + ' successfully.');
        }, function(response) {
            var params = {label: 'Error adding mod', response: response};
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
            $scope.reAddMod(existingMod);
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
        $scope.removeRequirements(modListMod.mod.id);
        $scope.removeNotes(modListMod.mod.id);
        $scope.buildMissingMods();
        $scope.buildUnresolvedCompatibility();
        $scope.buildUnresolvedInstallOrder();
        $scope.mod_list.mods_count -= 1;
        $scope.updateTabs();
        $scope.$broadcast('updateItems');
    };

    $scope.$on('removeItem', function(event, modListMod) {
        $scope.removeMod(modListMod);
    });

    // direct method trigger events
    $scope.$on('rebuildModels', $scope.buildModsModel);
    $scope.$on('itemMoved', $scope.buildUnresolvedInstallOrder);
});