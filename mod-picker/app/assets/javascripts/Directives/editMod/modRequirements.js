app.directive('modRequirements', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modRequirements.html',
        scope: false,
        controller: 'modRequirementsController'
    }
});

app.controller('modRequirementsController', function ($scope) {
    $scope.addRequirement = function() {
        $scope.mod.requirements.push({});
    };

    $scope.removeRequirement = function(requirement) {
        var index = $scope.mod.requirements.indexOf(requirement);
        $scope.mod.requirements.splice(index, 1);
    };
});