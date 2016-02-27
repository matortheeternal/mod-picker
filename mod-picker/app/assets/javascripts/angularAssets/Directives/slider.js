

app.directive('slider', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/slider.html',
        controller: 'sliderController',
        scope: {
            data: '=',
            type: '@',
            attr: '@'
        }
    }
});

app.controller('sliderController', function ($scope, sliderOptionsFactory, $timeout) {
    if (typeof sliderOptionsFactory[$scope.type]=== "function") {
        $scope.options = sliderOptionsFactory[$scope.type]($scope.attr);
    }
    $scope.data = {
        minValue: $scope.options.min || 0,
        maxValue: $scope.options.max
    };
});