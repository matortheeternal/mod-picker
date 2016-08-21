app.directive('slider', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/slider.html',
        controller: 'sliderController',
        scope: {
            filters: '=?',
            data: '=',
            type: '@',
            attr: '@'
        }
    }
});

app.controller('sliderController', function ($scope, sliderOptionsFactory, $timeout) {
    if (typeof sliderOptionsFactory[$scope.type] === "function") {
        $scope.slider = sliderOptionsFactory[$scope.type]($scope.attr);
    }

    var filterData = $scope.filters[$scope.data];
    if (filterData) {
        $scope.rawData = {
            min: filterData.min,
            max: filterData.max
        }
    } else {
        $scope.rawData = {
            min: $scope.slider.min || 0,
            max: $scope.slider.max
        };
    }


    $scope.deleteData = function() {
        if ($scope.filters) {
            delete $scope.filters[$scope.data];
        } else {
            delete $scope.data;
        }
    };

    $scope.setData = function(min, max) {
        if ($scope.filters) {
            $scope.filters[$scope.data] = {
                min: min,
                max: max
            };
        } else {
            $scope.data = {
                min: min,
                max: max
            };
        }
    };

    $scope.$watch('rawData', function(rawData) {
        var stepsArray = $scope.slider.options.stepsArray;
        var atMin = rawData.min == 0;
        var atMax = rawData.max == parseInt($scope.attr) ||
            stepsArray && rawData.max == stepsArray.length - 1;
        // delete data and return if we're at default values
        if (atMin && atMax) {
            $scope.deleteData();
            return;
        }

        // set data using steps array if available, else use raw data
        if (stepsArray) {
            $scope.setData(stepsArray[rawData.min], stepsArray[rawData.max]);
        } else {
            $scope.setData(rawData.min, rawData.max);
        }
    }, true);

    $scope.$parent.$on('rerenderSliders', function () {
        $timeout(function () {
            $scope.$broadcast('rzSliderForceRender');
        });
    });
});