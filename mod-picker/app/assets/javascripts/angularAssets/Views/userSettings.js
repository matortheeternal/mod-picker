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

app.controller('userSettingsController', function ($scope, $q, $routeParams, userSettingsService) {
    $scope.currentTab = "Profile";

    $scope.canShowTab =function(tabName) {
        return $scope.currentTab === tabName;
    };

    userSettingsService.retrieveUserSettings($routeParams.userSettingsId).then(function (userSettings) {
        $scope.userSettings = userSettings;
    });

});