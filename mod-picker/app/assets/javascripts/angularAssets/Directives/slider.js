

app.directive('slider', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/slider.html',
        controller: 'sliderController',
        scope: {
            data: '=',
            min: '=',
            max: '=',
            options: '='
        }
    }
});

app.controller('sliderController', function ($scope) {
    $scope.data = {
        minValue: $scope.min,
        maxValue: $scope.max
    }
});