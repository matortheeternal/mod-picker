/**
 * Created by Sirius on 4/11/2016.
 */

app.directive('statBlock', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/statBlock.html',
        scope: {
            rows: '='
        }
    };
});
