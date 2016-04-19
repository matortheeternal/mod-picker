/**
 * Created by r79 on 2/11/2016.
 */

app.directive('linkSteamButton', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/linkSteamButton.html',
        controller: 'linkSteamButtonController',
        scope: {
            bio: '=',
        },
    };
});

app.controller('linkSteamButtonController', function ($scope) {
});
