app.controller('modListModsController', function($scope, modListService) {
    $scope.buildModsModel = function(mods, groups) {
        $scope.model.mods = [];
        groups.forEach(function(group) {
            if (group.tab !== 'mods') {
                return;
            }
            $scope.model.mods.push(group);
            group.children = mods.filter(function(mod) {
                return mod.group_id == group.id;
            });
        });
        mods.forEach(function(mod) {
            if (!mod.group_id) {
                var insertIndex = $scope.model.mods.findIndex(function(item) {
                    return item.index > mod.index;
                });
                $scope.model.mods.splice(insertIndex, 0, mod);
            }
        });
    };

    $scope.buildMissingMods = function(required_mods, mods) {
        $scope.shared.missing_mods = [];
        required_mods.forEach(function(requirement) {
            var modPresent = mods.find(function(modListMod) {
                return !modListMod._destroy && modListMod.mod.id == requirement.required_mod.id;
            });
            if (!modPresent) {
                $scope.shared.missing_mods.push(requirement);
            }
        });
    };

    $scope.retrieveMods = function() {
        $scope.retrieving.mods = true;
        modListService.retrieveModListMods($scope.mod_list.id).then(function(data) {
            $scope.buildMissingMods(data.required_mods, data.mods);
            $scope.buildModsModel(data.mods, data.groups);
            // We put this in shared because we don't want to detect changes to it as changes
            // to the mod list itself.  Changes in requirements are due to mods being added
            // or removed.
            $scope.shared.required_mods = data.required_mods;
            $scope.mod_list.mods = data.mods;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.mods = angular.copy($scope.mod_list.mods);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.retrieving.mods = false;
        }, function(response) {
            $scope.errors.mods = response;
        });
    };

    // retrieve mods if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.mods && !$scope.retrieving.mods) {
        $scope.retrieveMods();
    }

    $scope.addModGroup = function() {
        var newGroup = {
            mod_list_id: $scope.mod_list.id,
            index: $scope.model.mods.length,
            tab: 'mods',
            color: 'red',
            name: 'New Group'
        };
        modListService.newModListGroup(newGroup).then(function(data) {
            var group = data;
            group.children = [];
            $scope.mod_list.groups.push(group);
            $scope.originalModList.groups.push(angular.copy(group));
            $scope.model.mods.push(group);
        }, function(response) {
            var params = {label: 'Error creating new Mod List Group', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.reAddMod = function(modListMod) {
        // if mod is already present on the user's mod list but has been
        // removed, add it back
        if (modListMod._destroy) {
            delete modListMod._destroy;
            $scope.mod_list.mods_count += 1;
            $scope.reAddRequirements($scope.shared.required_mods, modListMod.id);
            $scope.buildMissingMods($scope.shared.required_mods, $scope.mod_list.mods);
            $scope.updateTabs();
            $scope.$emit('successMessage', 'Added mod ' + modListMod.mod.name + ' successfully.');
        }
        // else inform the user that the mod is already on their mod list
        else {
            $scope.$emit('customMessage', {type: 'error', text: 'Failed to add mod ' + modListMod.mod.name + ', the mod has already been added to this mod list.'});
        }
    };

    $scope.addNewMod = function(modId) {
        // retrieve mod information from the backend
        modListService.newModListMod(modId).then(function(data) {
            // prepare mod
            var modListMod = data;
            // we delete this because it's null, would be better if we just didn't render it though
            delete modListMod.id;
            modListMod.mod_id = modListMod.mod.id;

            // push mod onto view
            // TODO: Get new requirements and append them to the required_tools array
            $scope.buildMissingMods($scope.shared.required_mods, $scope.mod_list.mods);
            $scope.mod_list.mods.push(modListMod);
            $scope.model.mods.push(modListMod);
            $scope.mod_list.mods_count += 1;
            $scope.updateTabs();
            $scope.$emit('successMessage', 'Added mod ' + modListMod.mod.name + ' successfully.');
        }, function(response) {
            var params = {label: 'Error adding mod', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addMod = function() {
        // return if we don't have a mod to add
        if (!$scope.add.mod.id) {
            return;
        }

        // see if the mod is already present on the user's mod list
        var existingMod = $scope.mod_list.mods.find(function(modListMod) {
            return modListMod.mod.id == $scope.add.mod.id;
        });
        if (existingMod) {
            $scope.reAddMod(existingMod);
        } else {
            $scope.addNewMod($scope.add.mod.id);
        }

        // reset mod search
        $scope.add.mod.id = null;
        $scope.add.mod.name = "";
    };

    $scope.removeMod = function(array, index) {
        $scope.removeItem(array, index);
        $scope.buildMissingMods($scope.shared.required_mods, $scope.mod_list.mods);
        $scope.mod_list.mods_count -= 1;
        $scope.updateTabs();
    };

    $scope.$on('rebuildModels', function() {
        $scope.buildModsModel($scope.mod_list.mods, $scope.mod_list.groups);
        $scope.buildMissingMods($scope.shared.required_mods, $scope.mod_list.mods);
    });
});