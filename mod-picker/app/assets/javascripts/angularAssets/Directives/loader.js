/**
 * Created by r79 on 2/11/2016.
 */

app.directive('loader', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/loader.html',
        scope: {
            data: '='
        },
        transclude: true
    }
});