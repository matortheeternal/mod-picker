/**
 * Created by r79 on 2/11/2016.
 */

app.directive('linkNexusButton', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/linkNexusButton.html',
        scope: {
            bio: '=',
        },
    }
});
