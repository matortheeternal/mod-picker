/**
 * Created by Sirius on 3/9/2016.
 */
app.config(['$routeProvider', function ($routeProvider) {

    $routeProvider.when('/userSettings/:userSettingsId/profile', {
            templateUrl: '/resources/partials/userSettings/profile.html',
            controller: 'userSettingsController'
        }
    );
    $routeProvider.when('/userSettings/:userSettingsId/account', {
            templateUrl: '/resources/partials/userSettings/account.html',
            controller: 'userSettingsController'
        }
    );
    $routeProvider.when('/userSettings/:userSettingsId/reputation', {
            templateUrl: '/resources/partials/userSettings/reputation.html',
            controller: 'userSettingsController'
        }
    );
    $routeProvider.when('/userSettings/:userSettingsId/modlists', {
            templateUrl: '/resources/partials/userSettings/modlists.html',
            controller: 'userSettingsController'
        }
    );
    $routeProvider.when('/userSettings/:userSettingsId/authoredMods', {
            templateUrl: '/resources/partials/userSettings/authoredMods.html',
            controller: 'userSettingsController'
        }
    );
    $routeProvider.when('/userSettings/:userSettingsId/installation', {
            templateUrl: '/resources/partials/userSettings/installation.html',
            controller: 'userSettingsController'
        }
    );
}]);

app.controller('userSettingsController', function ($scope, $q, $routeParams, userSettingsService, userService) {
    useTwoColumns(false);

    userSettingsService.retrieveUserSettings($routeParams.userSettingsId).then(function (userSettings) {
        $scope.userSettings = userSettings;
        userService.retrieveUser(userSettings.user_id).then(function (user) {
            $scope.user = user;
        });
    });

    $scope.submit = function() {
        $scope.errors = [];
        $scope.showErrors = false;
        $scope.showSuccess = false;
        userSettingsService.submitUser($scope.user).then(function (data) {
            $scope.userSuccess = data.status === "ok";
            $scope.errors += data.errors;
            $scope.showErrors = !$scope.userSettingsSuccess || !$scope.userSuccess;
            $scope.showSuccess = $scope.userSettingsSuccess && $scope.userSuccess;
        });
        userSettingsService.submitUserSettings($scope.userSettings).then(function (data) {
            $scope.userSettingsSuccess = data.status === "ok";
            $scope.errors += data.errors;
            $scope.showErrors = !$scope.userSettingsSuccess || !$scope.userSuccess;
            $scope.showSuccess = $scope.userSettingsSuccess && $scope.userSuccess;
        });
    };
});
