/**
 * Created by r79 on 2/11/2016.
 */

app.directive('linkLoverButton', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/linkLoverButton.html',
        scope: {
            bio: '=',
        },
    }
});
