/**
 * Created by r79 on 2/11/2016.
 */

app.directive('expandable', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/expandable.html',
        controller: 'expandableController',
        scope: {
            expanded: '=',
            title: '='
        },
        transclude: true
    }
});

app.controller('expandableController', function ($scope) {
    $scope.toggle = function () {
        $scope.expanded = !$scope.expanded;
    }
});