app.directive('requiredMods', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/requiredMods.html',
        controller: 'requiredModsController',
        scope: false
    }
});

app.controller('requiredModsController', function($scope, $rootScope, requirementUtils) {
    $scope.showMissingMods = true;
    $scope.getRequirerList = requirementUtils.getModRequirerList;

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

    /* RESOLUTION ACTIONS */
    $scope.removeRequirers = function(requirement) {
        if (!$scope.model.tools) return;
        requirement.mods.forEach(function(mod) {
            $rootScope.$broadcast('removeMod', mod.id);
        });
    };

    $scope.resolveAllRequirements = function() {
        $scope.required.missing_mods.forEach(function(requirement) {
            $scope.addMod(requirement.required_mod.id)
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
    $scope.$on('modRemoved', function(event, mod) {
        if (mod) requirementUtils.removeRequirements(mod.id, $scope.required.mods, 'mod');
        $scope.buildMissingMods();
    });
    $scope.$on('modRecovered', function(event, modId) {
        if (modId) requirementUtils.recoverRequirements(modId, $scope.required.mods, 'mod');
        $scope.buildMissingMods();
    });
    $scope.$on('modAdded', function(event, modData) {
        var requirements = modData.required_mods;
        requirementUtils.addRequirements(requirements, $scope.required.mods, 'mod', 'required_mod');
        $scope.buildMissingMods();
    });
});