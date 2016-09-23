app.directive('slider', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/slider.html',
        controller: 'sliderController',
        scope: {
            filterData: '=?',
            filter: '='
        }
    }
});

// TODO: Sometime this needs to be refactored - the logic is pretty messy
app.controller('sliderController', function ($scope, sliderOptionsFactory, $timeout) {
    $scope.slider = sliderOptionsFactory.buildSlider($scope.filter);

    $scope.loadData = function(filterData) {
        var stepsArray = $scope.slider.options.stepsArray;
        if (stepsArray) {
            $scope.rawData = {
                min: stepsArray.indexOf(filterData.min),
                max: stepsArray.indexOf(filterData.max)
            }
        } else {
            $scope.rawData = {
                min: filterData.min,
                max: filterData.max
            };
        }
    };

    $scope.deleteData = function() {
        if ($scope.filterData) {
            delete $scope.filterData[$scope.filter.data];
        } else {
            delete $scope.filter.data;
        }
    };

    $scope.setData = function(min, max) {
        if ($scope.filterData) {
            $scope.filterData[$scope.filter.data] = {
                min: min,
                max: max
            };
        } else {
            $scope.filter.data = {
                min: min,
                max: max
            };
        }
    };

    $scope.$watch('rawData', function(rawData) {
        var stepsArray = $scope.slider.options.stepsArray;
        var atMin = rawData.min == 0;
        var atMax = rawData.max == $scope.filter.max ||
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

    // load data from $scope.filterData if present
    var filterData = $scope.filterData[$scope.filter.data];
    if (filterData) {
        $scope.loadData(filterData);
    } else {
        $scope.rawData = {
            min: $scope.slider.min || 0,
            max: $scope.slider.max
        };
    }
});