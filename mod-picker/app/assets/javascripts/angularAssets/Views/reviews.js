
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/reviews', {
            templateUrl: '/resources/partials/reviews.html',
            controller: 'reviewsController'
        }
    );
}]);

app.controller('reviewsController', function ($scope, $q, backend) {
    $scope.loading = true;

    /* slider prototypes */
    var start = new Date(2016,0,1);
    $scope.dateSlider = {
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: generateDateSteps(start)
        }
    };

    /* date sliders */
    $scope.slSubmitted = {
        minValue: 0,
        maxValue: 51
    };
    $scope.slEdited = {
        minValue: 0,
        maxValue: 51
    };

    /* rating slider */
    $scope.slRating = {
        minValue: 0,
        maxValue: 100,
        option: {
            hideLimitLabels: true,
            noSwitching: true
        }
    };

    /* helpfulness slider */
    $scope.slHelpfulness = {
        minValue: 0,
        maxValue: 60,
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: generateSteps(1, 500)
        }
    };


    /* data */
    backend.retrieveReviews().then(function (data) {
        $scope.reviews = data;
        $scope.loading = false;
    });
});