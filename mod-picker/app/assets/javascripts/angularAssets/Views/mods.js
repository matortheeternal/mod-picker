
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, backend) {
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
            stepsArray: generateDateSteps(start)
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
            stepsArray: generateSteps(5, 500000)
        }
    };
    $scope.slUniqueDownloads = {
        minValue: 0,
        maxValue: 140,
        options: {
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: generateSteps(50, 10000000)
        }
    };
    $scope.slTotalDownloads = {
        minValue: 0,
        maxValue: 150,
        options: {
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: generateSteps(100, 50000000)
        }
    };
    $scope.slViews = {
        minValue: 0,
        maxValue: 150,
        options: {
            noSwitching: true,
            hideLimitLabels: true,
            stepsArray: generateSteps(100, 50000000)
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
            stepsArray: generateSteps(5, 50000)
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
            stepsArray: generateSteps(1, 1000)
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
            stepsArray: generateSteps(1, 1000)
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
    backend.retrieveMods().then(function (data) {
        $scope.mods = data;
        $scope.loading = false;
    });
});


function generateSteps(initialSpacing, maxValue) {
    var array = [0];
    var c = 0;
    var spacing = initialSpacing;
    for (i = 1; c < maxValue; i++) {
        c += spacing;
        if ((c >= 100) && (i % 10 == 0)) {
            if (Math.log10(spacing) % 1 != 0) {
                spacing = c / 10;
            } else {
                spacing = (c * 1.5) / 10;
            }
        }
        array.push(c);
    }
    return array;
}

function generateDateSteps(minDate) {
    var c = new Date();
    var array = ["Now"];
    var minValue = minDate.getTime();

    // hours
    for (i = 0; (c.getTime() > minValue) && (i < 23); i++) {
        if (i == 0) {
            array.unshift("1 hour ago");
        } else {
            array.unshift((i + 1) + " hours ago");
        }
        c.setHours(c.getHours() - 1);
    }

    // days
    for (i = 0; (c.getTime() > minValue) && (i < 24); i++) {
        array.unshift(c.toLocaleDateString());
        c.setDate(c.getDate() - 1);
    }

    // weeks
    for (i = 0; (c.getTime() > minValue) && (i < 36); i++) {
        array.unshift(c.toLocaleDateString());
        c.setDate(c.getDate() - 7);
    }

    // months
    for (i = 0; (c.getTime() > minValue) && (i < 48); i++) {
        array.unshift(c.toLocaleDateString());
        c.setMonth(c.getMonth() - 1);
    }

    // quarters
    for (i = 0; (c.getTime() > minValue) && (i < 24); i++) {
        array.unshift(c.toLocaleDateString());
        c.setMonth(c.getMonth() - 3);
    }

    // half years
    for (i = 0; (c.getTime() > minValue) && (i < 24); i++) {
        array.unshift(c.toLocaleDateString());
        c.setMonth(c.getMonth() - 6);
    }

    // last date
    array[0] = minDate.toLocaleDateString();
    return array;
}