
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/users', {
            templateUrl: '/resources/partials/users.html',
            controller: 'usersController'
        }
    );
}]);

app.controller('usersController', function ($scope, $q, backend, sliderFactory) {
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
    $scope.slJoined = {
        minValue: 0,
        maxValue: 51
    };
    $scope.slLastSeen = {
        minValue: 0,
        maxValue: 51
    };

    /* stat sliders */
    $scope.slReputation = {
        minValue: 0,
        maxValue: 70,
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: sliderFactory.generateSteps(5, 5000)
        }
    };
    $scope.slMods = {
        minValue: 0,
        maxValue: 100,
        options: {
            floor: 0,
            ceil: 100,
            hideLimitLabels: true,
            noSwitching: true
        }
    };
    $scope.slCompatibilityNotes = {
        minValue: 0,
        maxValue: 60,
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: sliderFactory.generateSteps(1, 500)
        }
    };
    $scope.slInstallationNotes = {
        minValue: 0,
        maxValue: 60,
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: sliderFactory.generateSteps(1, 500)
        }
    };
    $scope.slIncorrectNotes = {
        minValue: 0,
        maxValue: 60,
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: sliderFactory.generateSteps(1, 500)
        }
    };
    $scope.slComments = {
        minValue: 0,
        maxValue: 60,
        options: {
            hideLimitLabels: true,
            noSwitching: true,
            stepsArray: sliderFactory.generateSteps(1, 500)
        }
    };
    $scope.slModLists = {
        minValue: 0,
        maxValue: 100,
        options: {
            floor: 0,
            ceil: 100,
            hideLimitLabels: true,
            noSwitching: true
        }
    };


    /* data */
    backend.retrieveUsers().then(function (data) {
        $scope.users = data;
        $scope.loading = false;
    });
});