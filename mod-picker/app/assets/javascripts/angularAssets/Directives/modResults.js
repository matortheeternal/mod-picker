/**
 * Created by r79 on 2/11/2016.
 */

app.directive('modResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modResults.html',
        scope: {
            data: '='
        }
    }
});