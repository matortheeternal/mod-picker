/**
 * Created by Sirius on 3/9/2016.
 */
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/userSettings/:userSettingsId', {
            templateUrl: '/resources/partials/userSettings.html',
            controller: 'userSettingsController'
        }
    );
}]);

app.controller('userSettingsController', function ($scope, $q, $routeParams, userSettingsService, userService) {
    useTwoColumns(false);
    $scope.currentTab = "Profile";

    $scope.setClass = function(startClass, endClass, bool) {
        if(bool)
            return endClass;
        else
            return startClass;
    };


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

        //scrolls to the top of the page
        window.scrollTo(0, 0);
    };
});
