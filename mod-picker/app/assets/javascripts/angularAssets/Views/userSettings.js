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
        userSettingsService.submitUser($scope.user).then(function (data) {
            if (data.status === "ok" && !$scope.errors.length) {
                $scope.showSuccess = true;
            }
            else
                $scope.errors += data.errors;
        });
        userSettingsService.submitUserSettings($scope.userSettings).then(function (data) {
            if (data.status === "ok" && !$scope.errors.length) {
                $scope.showSuccess = true;
            }
            else
                $scope.errors += data.errors;
        });
    };
});
