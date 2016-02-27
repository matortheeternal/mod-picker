/**
 * Created by mator on 2/20/2016.
 */

app.directive('cnoteResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/cnoteResults.html',
        scope: {
            data: '='
        }
    }
});