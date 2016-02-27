/**
 * Created by mator on 2/20/2016.
 */

app.directive('reviewResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/reviewResults.html',
        scope: {
            data: '='
        }
    }
});