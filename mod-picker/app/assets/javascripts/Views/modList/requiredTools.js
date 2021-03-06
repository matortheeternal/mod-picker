app.directive('requiredTools', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/requiredTools.html',
        controller: 'requiredToolsController',
        scope: false
    }
});

app.controller('requiredToolsController', function($scope, $rootScope, requirementUtils) {
    $scope.showMissingTools = true;

    /* BUILD VIEW MODEL */
    $scope.buildMissingTools = function() {
        $scope.required.missing_tools = [];
        $scope.required.tools.forEach(function(requirement) {
            // skip destroyed requirements
            if (!requirement.mods.length) {
                return;
            }
            var requiredToolPresent = $scope.findTool(requirement.required_mod.id, true);
            if (!requiredToolPresent) {
                if (requirementUtils.findOne([$scope.findTool, $scope.findMod], requirement.mods)) {
                    $scope.required.missing_tools.push(requirement);
                }
            }
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
        if (!$scope.model.mods) return;
        requirement.mods.forEach(function(mod) {
            $rootScope.$broadcast('removeMod', mod.id);
        });
    };

    $scope.resolveAllRequirements = function() {
        $scope.required.missing_tools.forEach(function(requirement) {
            $scope.addTool(requirement.required_mod.id)
        });
    };

    /* EVENT TRIGGERS */
    $scope.$on('initializeModules', function() {
        requirementUtils.compactRequirements($scope.required.tools, 'mod', 'required_mod');
        $scope.buildMissingTools();
    });
    $scope.$on('reloadModules', function() {
        requirementUtils.recoverDestroyedRequirements($scope.required.tools, 'mod');
        $scope.buildMissingTools();
    });
    $scope.$on('saveChanges', function() {
        requirementUtils.removeDestroyedRequirements($scope.required.tools, 'mod');
        $scope.buildMissingTools();
    });
    $scope.$on('modRemoved', function(event, mod) {
        if (mod) requirementUtils.removeRequirements(mod.id, $scope.required.tools, 'mod');
        $scope.buildMissingTools();
    });
    $scope.$on('modRecovered', function(event, modId) {
        if (modId) requirementUtils.recoverRequirements(modId, $scope.required.tools, 'mod');
        $scope.buildMissingTools();
    });
    $scope.$on('modAdded', function(event, modData) {
        var requirements = modData.required_tools;
        requirementUtils.addRequirements(requirements, $scope.required.tools, 'mod', 'required_mod');
        $scope.buildMissingTools();
    });
});