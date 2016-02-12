/**
 * Created by r79 on 2/11/2016.
 */

app.directive('modList', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList.html',
        scope: {
            data: '='
        }
    }
});