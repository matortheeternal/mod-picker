app.directive('requiredMods', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/requiredMods.html',
        controller: 'requiredModsController',
        scope: false
    }
});

app.controller('requiredModsController', function($scope, requirementUtils) {
    /* BUILD VIEW MODEL */
    $scope.buildMissingMods = function() {
        $scope.required.missing_mods = [];
        $scope.required.mods.forEach(function(requirement) {
            // skip destroyed requirements
            if (!requirement.mods.length) {
                return;
            }
            var requiredModPresent = $scope.findMod(requirement.required_mod.id, true);
            if (!requiredModPresent) {
                if (requirementUtils.findOne([$scope.findTool, $scope.findMod], requirement.mods)) {
                    $scope.required.missing_mods.push(requirement);
                }
            }
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
        requirementUtils.compactRequirements($scope.required.mods, 'mod', 'required_mod');
        $scope.buildMissingMods();
    });
    $scope.$on('reloadModules', function() {
        requirementUtils.recoverDestroyedRequirements($scope.required.mods, 'mod');
        $scope.buildMissingMods();
    });
    $scope.$on('saveChanges', function() {
        requirementUtils.removeDestroyedRequirements($scope.required.mods, 'mod');
        $scope.buildMissingMods();
    });
    $scope.$on('modRemoved', function(event, modId) {
        requirementUtils.removeRequirements(modId, $scope.required.mods, 'mod');
        $scope.buildMissingMods();
    });
    $scope.$on('modRecovered', function(event, modId) {
        requirementUtils.recoverRequirements(modId, $scope.required.mods, 'mod');
        $scope.buildMissingMods();
    });
    $scope.$on('modAdded', function(event, modData) {
        var requirements = modData.required_mods;
        requirementUtils.addRequirements(requirements, $scope.required.mods, 'mod', 'required_mod');
        $scope.buildMissingMods();
    });
});