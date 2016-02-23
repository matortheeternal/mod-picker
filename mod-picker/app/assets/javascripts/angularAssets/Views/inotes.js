
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/installation_notes', {
            templateUrl: '/resources/partials/installation_notes.html',
            controller: 'inotesController'
        }
    );
}]);

app.controller('inotesController', function ($scope, $q, backend, sliderFactory) {
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
    backend.retrieveInstallationNotes().then(function (data) {
        $scope.inotes = data;
        $scope.loading = false;
    });
});