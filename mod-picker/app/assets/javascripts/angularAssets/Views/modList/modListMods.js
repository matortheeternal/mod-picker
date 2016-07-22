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
            $scope.mod_list.required_mods = data.required_mods;
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

    $scope.removeMod = function(array, index) {
        $scope.removeItem(array, index);
        // TODO: remove requirements
        // TODO: add missing requirements
        $scope.mod_list.mods_count -= 1;
        $scope.updateTabs();
    };

    $scope.$on('rebuildModels', function() {
        $scope.buildModsModel($scope.mod_list.mods, $scope.mod_list.groups);
        $scope.buildMissingMods($scope.mod_list.required_mods, $scope.mod_list.mods);
    });
});