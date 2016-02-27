/**
 * Created by mator on 2/20/2016.
 */

app.directive('userResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userResults.html',
        scope: {
            data: '='
        }
    }
});