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
    var timeOut;
    $scope.showSpinner = false;
    $scope.$watch('data', function (newValue, oldValue) {
        if(!newValue) {
            if(!timeOut) {
                timeOut = setTimeout(function () {
                    $scope.showSpinner = true;
                }, 100);
            }
        } else {
            clearTimeout(timeOut);
            $scope.showSpinner = false;
        }
    });
});