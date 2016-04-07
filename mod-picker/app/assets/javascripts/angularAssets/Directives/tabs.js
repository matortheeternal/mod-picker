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
        	tabs: '=',
        	currentTab: '='
        }
    }
});


app.directive('columnTabs', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/columnTabs.html',
        controller: 'tabsController',
        scope: {
            tabs: '=',
            currentTab: '='
        }
    }
});


app.controller('tabsController', function ($scope) {

	$scope.select = function (nextTab) {
		$scope.currentTab = nextTab;
	};
});
