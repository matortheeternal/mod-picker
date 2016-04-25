

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
        $scope.slider = sliderOptionsFactory[$scope.type]($scope.attr);
    }
    $scope.data = {};
    $scope.rawData = {
        min: $scope.slider.min || 0,
        max: $scope.slider.max
    };

    $scope.$watch('rawData', function(rawData) {
        if ($scope.slider.options.stepsArray) {
            $scope.data.min = $scope.slider.options.stepsArray[rawData.min];
            $scope.data.max = $scope.slider.options.stepsArray[rawData.max];
        } else {
            $scope.data.min = rawData.min;
            $scope.data.max = rawData.max;
        }
    }, true);

    $scope.$parent.$on('rerenderSliders', function () {
        $timeout(function () {
            $scope.$broadcast('rzSliderForceRender');
        });
    });
});