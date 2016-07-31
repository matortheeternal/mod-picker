app.directive('requiredTools', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/requiredTools.html',
        controller: 'requiredToolsController',
        scope: false
    }
});

app.controller('requiredToolsController', function($scope) {
    /* BUILD VIEW MODEL */
    $scope.compactRequiredTools = function() {
        var requirements = $scope.required.tools;
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

    $scope.buildMissingTools = function() {
        $scope.required.missing_tools = [];
        $scope.required.tools.forEach(function(requirement) {
            // skip destroyed requirements
            if (requirement._destroy) {
                return;
            }
            var toolPresent = $scope.findTool(requirement.required_mod.id, true);
            // TODO: Check if one of the mods in the mods array is present
            if (!toolPresent) {
                $scope.required.missing_tools.push(requirement);
            }
        });
    };

    /* UPDATE VIEW MODEL */
    $scope.addRequirements = function(requirements) {
        requirements.forEach(function(newRequirement) {
            var foundRequirement = $scope.required.tools.find(function(requirement) {
                return requirement.required_mod.id == newRequirement.required_mod.id;
            });
            if (foundRequirement) {
                foundRequirement.mods.push(newRequirement.mod);
            } else {
                newRequirement.mods = [newRequirement.mod];
                newRequirement.destroyed_mods = [];
                delete newRequirement.mod;
                $scope.required.tools.push(newRequirement);
            }
        });
    };

    $scope.removeRequirements = function(toolId) {
        $scope.required.tools.forEach(function(requirement) {
            var index = requirement.mods.findIndex(function(mod) {
                return mod.id == toolId;
            });
            if (index > -1) {
                var mod = requirement.mods.splice(index, 1)[0];
                requirement.destroyed_mods.push(mod);
            }
        });
    };

    $scope.recoverRequirements = function(toolId) {
        $scope.required.tools.forEach(function(requirement) {
            var index = requirement.destroyed_mods.findIndex(function(mod) {
                return mod.id == toolId;
            });
            if (index > -1) {
                var mod = requirement.destroyed_mods.splice(index, 1)[0];
                requirement.mods.push(mod);
            }
        });
    };

    $scope.recoverAllRequirements = function() {
        $scope.required.tools.forEach(function(requirement) {
            requirement.mods.unite(requirement.destroyed_mods);
            requirement.destroyed_mods = [];
        });
    };

    /* HELPER FUNCTIONS */
    $scope.getRequirerList = function(requirement, startIndex) {
        return requirement.mods.slice(startIndex).map(function(tool) {
            return tool.name;
        }).join(', ');
    };

    /* RESOLUTION ACTIONS */
    $scope.removeRequirers = function(requirement) {
        requirement.mods.forEach(function(mod) {
            $scope.removeTool($scope.findTool(mod.id, true));
        });
    };

    /* EVENT TRIGGERS */
    $scope.$on('initializeModules', function() {
        $scope.compactRequiredTools();
        $scope.buildMissingTools();
    });
    $scope.$on('reloadModules', function() {
        $scope.recoverAllRequirements();
        $scope.buildMissingTools();
    });
    $scope.$on('modRemoved', function(event, modId) {
        $scope.removeRequirements(modId);
        $scope.buildMissingTools();
    });
    $scope.$on('modRecovered', function(event, modId) {
        $scope.recoverRequirements(modId);
        $scope.buildMissingTools();
    });
    $scope.$on('modAdded', function(event, modData) {
        $scope.addRequirements(modData.required_tools);
        $scope.buildMissingTools();
    });
});