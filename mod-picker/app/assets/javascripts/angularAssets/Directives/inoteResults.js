/**
 * Created by mator on 2/20/2016.
 */

app.directive('inoteResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/inoteResults.html',
        scope: {
            data: '='
        }
    }
});