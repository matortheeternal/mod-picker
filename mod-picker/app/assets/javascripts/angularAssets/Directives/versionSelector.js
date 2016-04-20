/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('versionSelector', function () {
    return {
    	transclude: true,
        restrict: 'E',
        templateUrl: '/resources/directives/versionSelector.html',
        controller: 'versionSelectorController',
        scope: {
        	versions: '=',
            selectedVersions: '='
        }
    }
});

app.controller('versionSelectorController', function ($scope) {
    $scope.selectedVersions = [];
    $scope.addToSelected = function(version, checked) {
        if (checked) {
            selectedVersions.push(version);
        }
    };
    $scope.applyToAll = function() {

    };
});
