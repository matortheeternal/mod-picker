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
    // TODO: Apply everything to both $scope.required.mods and $scope.required.tools
    $scope.buildMissingMods = function() {
        $scope.required.missing_mods = [];
        $scope.required.mods.forEach(function(requirement) {
            // skip destroyed requirements
            if (requirement._destroy) {
                return;
            }
            var modPresent = $scope.findMod(requirement.required_mod.id, true);
            if (!modPresent) {
                $scope.required.missing_mods.push(requirement);
            }
        });
    };

    $scope.reAddModRequirements = function(modId) {
        $scope.required.mods.forEach(function(requirement) {
            if (requirement._destroy && requirement.mod.id == modId) {
                delete requirement._destroy;
            }
        });
    };

    $scope.removeRequirements = function(modId) {
        $scope.required.mods.forEach(function(requirement) {
            if (requirement.mod.id == modId) {
                requirement._destroy = true;
            }
        });
    };

    // direct method trigger events
    $scope.$on('rebuildMissingMods', $scope.buildMissingMods);
});