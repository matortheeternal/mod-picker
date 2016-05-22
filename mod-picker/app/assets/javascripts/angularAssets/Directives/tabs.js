/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('tabs', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tabs.html',
        controller: 'tabsController',
        scope: {
        	tabs: '='
        }
    };
});

app.controller('tabsController', function($scope, $state) {
    $state.go('.' + $scope.tabs[0]);
});
