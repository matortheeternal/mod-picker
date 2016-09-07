/**
 * Created by r79 on 2/11/2016.
 */

app.directive('twoColumns', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/layout/twoColumns.html',
        transclude: true
    };
});
