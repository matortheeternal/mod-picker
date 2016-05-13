/**
 * Created by r79 on 2/11/2016.
 */

app.directive('linkWorkshopAccount', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/linkWorkshopAccount.html',
        controller: 'linkWorkshopAccountController',
        scope: {
            bio: '='
        }
    };
});

app.controller('linkWorkshopAccountController', function ($scope, userSettingsService) {

});
