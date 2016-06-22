/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('versionBoxes', function () {
    return {
        transclude: true,
        restrict: 'E',
        templateUrl: '/resources/directives/versionBoxes.html',
        controller: 'versionBoxesController',
        scope: {
            versions: '=',
            selectedVersions: '='
        }
    }
});

app.controller('versionBoxesController', function ($scope) {
    $scope.selectedVersions = [];
    $scope.addToSelected = function(version, checked) {
        if (checked) {
            selectedVersions.push(version);
        }
    };
    $scope.applyToAll = function() {

    };
});
