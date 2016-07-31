app.directive('requiredMods', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/requiredMods.html',
        controller: 'requiredModsController',
        scope: false
    }
});

app.controller('requiredModsController', function($scope) {
    /* BUILD VIEW MODEL */
    $scope.compactRequiredMods = function() {
        var requirements = $scope.required.mods;
        var req, prev;
        for (var i = requirements.length - 1; i >= 0; i--) {
            req = requirements[i];
            if (prev && req.required_mod.id == prev.required_mod.id) {
                prev.mods.unshift(req.mod);
                requirements.splice(i, 1);
            } else {
                req.mods = [req.mod];
                req.destroyed_mods = [];
                delete req.mod;
                prev = req;
            }
        }
    };

    $scope.buildMissingMods = function() {
        $scope.required.missing_mods = [];
        $scope.required.mods.forEach(function(requirement) {
            // skip destroyed requirements
            if (requirement._destroy) {
                return;
            }
            var modPresent = $scope.findMod(requirement.required_mod.id, true);
            // TODO: Check if one of the mods in the mods array is present
            if (!modPresent) {
                $scope.required.missing_mods.push(requirement);
            }
        });
    };

    /* UPDATE VIEW MODEL */
    $scope.addRequirements = function(requirements) {
        requirements.forEach(function(newRequirement) {
            var foundRequirement = $scope.required.mods.find(function(requirement) {
                return requirement.required_mod.id == newRequirement.required_mod.id;
            });
            if (foundRequirement) {
                foundRequirement.mods.push(newRequirement.mod);
            } else {
                newRequirement.mods = [newRequirement.mod];
                newRequirement.destroyed_mods = [];
                delete newRequirement.mod;
                $scope.required.mods.push(newRequirement);
            }
        });
    };

    $scope.removeRequirements = function(modId) {
        $scope.required.mods.forEach(function(requirement) {
            var index = requirement.mods.findIndex(function(mod) {
                return mod.id == modId;
            });
            if (index > -1) {
                var mod = requirement.mods.splice(index, 1)[0];
                requirement.destroyed_mods.push(mod);
            }
        });
    };

    $scope.recoverRequirements = function(modId) {
        $scope.required.mods.forEach(function(requirement) {
            var index = requirement.destroyed_mods.findIndex(function(mod) {
                return mod.id == modId;
            });
            if (index > -1) {
                var mod = requirement.destroyed_mods.splice(index, 1)[0];
                requirement.mods.push(mod);
            }
        });
    };

    $scope.recoverAllRequirements = function() {
        $scope.required.mods.forEach(function(requirement) {
            requirement.mods.unite(requirement.destroyed_mods);
            requirement.destroyed_mods = [];
        });
    };

    /* HELPER FUNCTIONS */
    $scope.getRequirerList = function(requirement, startIndex) {
        return requirement.mods.slice(startIndex).map(function(mod) {
            return mod.name;
        }).join(', ');
    };

    /* RESOLUTION ACTIONS */
    $scope.removeRequirers = function(requirement) {
        requirement.mods.forEach(function(mod) {
            $scope.removeMod($scope.findMod(mod.id, true));
        });
    };

    /* EVENT TRIGGERS */
    $scope.$on('initializeModules', function() {
        $scope.compactRequiredMods();
        $scope.buildMissingMods();
    });
    $scope.$on('reloadModules', function() {
        $scope.recoverAllRequirements();
        $scope.buildMissingMods();
    });
    $scope.$on('modRemoved', function(event, modId) {
        $scope.removeRequirements(modId);
        $scope.buildMissingMods();
    });
    $scope.$on('modRecovered', function(event, modId) {
        $scope.recoverRequirements(modId);
        $scope.buildMissingMods();
    });
    $scope.$on('modAdded', function(event, modData) {
        $scope.addRequirements(modData.required_mods);
        $scope.buildMissingMods();
    });
});