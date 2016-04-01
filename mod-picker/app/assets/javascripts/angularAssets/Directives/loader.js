/**
 * Created by r79 on 2/11/2016.
 */

app.directive('loader', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/loader.html',
        scope: {
            data: '='
        },
        controller: 'loaderController',
        transclude: true
    }
});

app.controller('loaderController', function ($scope) {
    $scope.showSpinner = false;
    $scope.$watch('data', function (newValue) {
        $scope.showSpinner = !newValue;
    });
});