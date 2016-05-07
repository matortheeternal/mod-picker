/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('tabs', function () {
    return {
    	transclude: true,
        restrict: 'E',
        templateUrl: '/resources/directives/tabs.html',
        controller: 'tabsController',
        scope: {
        	tabs: '='
        }
    };
});

app.controller('tabsController', function ($scope, $state) {
    $scope.state = {selected: 0};
    $state.go('^.tab1');
});
