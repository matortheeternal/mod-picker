/**
 * Created by r79 on 2/11/2016.
 */

app.directive('linkLoverButton', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/linkLoverButton.html',
        controller: 'linkLoverButtonController',
        scope: {
            bio: '=',
        },
    }
});

app.controller('linkLoverButtonController', function ($scope) {
});
