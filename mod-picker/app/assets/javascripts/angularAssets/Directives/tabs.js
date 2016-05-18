/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('tabs', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tabs.html',
        scope: {
        	tabs: '='
        },
        link: function(scope) {
            scope.state = {selected: 0};
            state.go('.' + scope.tabs[0]);
        }
    };
});
