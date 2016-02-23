
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, modService, sliderFactory) {
    $scope.loading = true;

    /* visibility of extended filters */
    $scope.nm_visible = false;
    $scope.nm_toggle = function () {
        $scope.nm_visible = !$scope.nm_visible;
        if ($scope.nm_visbile) {
            $scope.$broadcast('rzSliderForceRender');
        }
    };

    $scope.mp_visible = false;
    $scope.mp_toggle = function () {
        $scope.mp_visible = !$scope.mp_visible;
        if ($scope.mp_visbile) {
            $scope.$broadcast('rzSliderForceRender');
        }
    };

    /* slider prototypes */
    var start = new Date(2011,10,11);
    $scope.dateSlider = {
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: sliderFactory.generateDateSteps(start)
        }
    };

    /* date sliders */
    $scope.slUpdated = {
        minValue: 0,
        maxValue: 126
    };
    $scope.slReleased = {
        minValue: 0,
        maxValue: 126
    };

    /* nexus mods stat sliders */
    $scope.slEndorsements = {
        minValue: 0,
        maxValue: 130,
        options: {
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: sliderFactory.generateSteps(5, 500000)
        }
    };
    $scope.slUniqueDownloads = {
        minValue: 0,
        maxValue: 140,
        options: {
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: sliderFactory.generateSteps(50, 10000000)
        }
    };
    $scope.slTotalDownloads = {
        minValue: 0,
        maxValue: 150,
        options: {
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: sliderFactory.generateSteps(100, 50000000)
        }
    };
    $scope.slViews = {
        minValue: 0,
        maxValue: 150,
        options: {
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: sliderFactory.generateSteps(100, 50000000)
        }
    };
    $scope.slPosts = {
        minValue: 0,
        maxValue: 100,
        options: {
            floor: 0,
            ceil: 100,
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: sliderFactory.generateSteps(5, 50000)
        }
    };
    $scope.slVideos = {
        minValue: 0,
        maxValue: 50,
        options: {
            floor: 0,
            ceil: 50,
            noSwitching: true,
            hideLimitLabels: true
        }
    };
    $scope.slImages = {
        minValue: 0,
        maxValue: 130,
        options: {
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: sliderFactory.generateSteps(1, 1000)
        }
    };
    $scope.slFiles = {
        minValue: 0,
        maxValue: 200,
        options: {
            floor: 0,
            ceil: 200,
            noSwitching: true,
            hideLimitLabels: true
        }
    };
    $scope.slArticles = {
        minValue: 0,
        maxValue: 50,
        options: {
            floor: 0,
            ceil: 50,
            noSwitching: true,
            hideLimitLabels: true
        }
    };

    /* mod picker sliders */
    $scope.slReputation = {
        minValue: 0,
        maxValue: 450,
        options: {
            floor: 0,
            ceil: 450,
            noSwitching: true,
            hideLimitLabels: true
        }
    };
    $scope.slRating = {
        minValue: 0,
        maxValue: 100,
        options: {
            floor: 0,
            ceil: 100,
            noSwitching: true,
            hideLimitLabels: true
        }
    };
    $scope.slReviews = {
        minValue: 0,
        maxValue: 200,
        options: {
            floor: 0,
            ceil: 200,
            noSwitching: true,
            hideLimitLabels: true
        }
    };
    $scope.slStars = {
        minValue: 0,
        maxValue: 130,
        options: {
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: sliderFactory.generateSteps(1, 1000)
        }
    };
    $scope.slCnotes = {
        minValue: 0,
        maxValue: 100,
        options: {
            floor: 0,
            ceil: 100,
            noSwitching: true,
            hideLimitLabels: true
        }
    };
    $scope.slInotes = {
        minValue: 0,
        maxValue: 100,
        options: {
            floor: 0,
            ceil: 100,
            noSwitching: true,
            hideLimitLabels: true
        }
    };

    /* data */
    modService.retrieveMods().then(function (data) {
        $scope.mods = data;
        $scope.loading = false;
    });
});