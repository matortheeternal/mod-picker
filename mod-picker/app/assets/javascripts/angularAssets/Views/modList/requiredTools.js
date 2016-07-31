app.directive('requiredTools', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/requiredTools.html',
        controller: 'requiredToolsController',
        scope: false
    }
});

app.controller('requiredToolsController', function($scope, requirementUtils) {
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
                // TODO: Check if one of the mods in the mods array is present
                $scope.required.missing_tools.push(requirement);
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
        requirement.mods.forEach(function(mod) {
            $scope.removeTool($scope.findTool(mod.id, true));
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
        $scope.buildMissingPlugins();
    });
    $scope.$on('modRemoved', function(event, modId) {
        requirementUtils.removeRequirements(modId, $scope.required.tools, 'mod');
        $scope.buildMissingTools();
    });
    $scope.$on('modRecovered', function(event, modId) {
        requirementUtils.recoverRequirements(modId, $scope.required.tools, 'mod');
        $scope.buildMissingTools();
    });
    $scope.$on('modAdded', function(event, modData) {
        var requirements = modData.required_tools;
        requirementUtils.addRequirements(requirements, $scope.required.tools, 'mod', 'required_mod');
        $scope.buildMissingTools();
    });
});