/**
 * Created by Sirius on 3/9/2016.
 */
app.config(['$routeProvider', function ($routeProvider) {

    $routeProvider.when('/settings', {
            templateUrl: '/resources/partials/userSettings/userSettings.html',
            controller: 'userSettingsController'
        }
    );
}]);

app.controller('userSettingsController', function ($scope, $q, userSettingsService, userService) {
    useTwoColumns(false);

    $scope.tabs = [
        { name: 'Profile', url: '/resources/partials/userSettings/profile.html'},
        { name: 'Account', url: '/resources/partials/userSettings/account.html'},
        { name: 'Reputation', url: '/resources/partials/userSettings/reputation.html'},
        { name: 'Mod Lists', url: '/resources/partials/userSettings/modlists.html'},
        { name: 'Authored Mods', url: '/resources/partials/userSettings/authoredMods.html'}
    ];

    $scope.currentTab = $scope.tabs[0];


    userSettingsService.retrieveUserSettings().then(function (userSettings) {
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
