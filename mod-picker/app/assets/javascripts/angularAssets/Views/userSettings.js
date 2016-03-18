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
    $scope.showErrors = false;
    $scope.showSuccess = false;

    $scope.isSelected = function(tabName) {
        return $scope.currentTab === tabName;
    };

    $scope.cssClass = function(tabName) {
        if($scope.isSelected(tabName))
            return "selected-tab";
        else
            return "unselected-tab";
    };


    userSettingsService.retrieveUserSettings($routeParams.userSettingsId).then(function (userSettings) {
        $scope.userSettings = userSettings;
        userService.retrieveUser(userSettings.user_id).then(function (user) {
            $scope.user = user;
        });
    });

    $scope.submit = function() {
        $scope.errors = [];
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
