
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/compatibility_notes', {
            templateUrl: '/resources/partials/compatibility_notes.html',
            controller: 'cnotesController'
        }
    );
}]);

app.controller('cnotesController', function ($scope, $q, backend, sliderFactory) {
    $scope.loading = true;

    /* slider prototypes */
    var start = new Date(2016,0,1);
    $scope.dateSlider = {
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: sliderFactory.generateDateSteps(start)
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

    /* helpfulness slider */
    $scope.slHelpfulness = {
        minValue: 0,
        maxValue: 60,
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: sliderFactory.generateSteps(1, 500)
        }
    };

    /* data */
    backend.retrieveCompatibilityNotes().then(function (data) {
        $scope.cnotes = data;
        $scope.loading = false;
    });
});