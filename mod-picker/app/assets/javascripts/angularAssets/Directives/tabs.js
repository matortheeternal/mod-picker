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
        	currentTab: '=',
            onChange: '=?'
        }
    }
});

app.controller('tabsController', function ($scope) {
    //TODO: I feel like this logic can be done inside the scope
    //this can't happen unless we stop using ng-include
    //(it creates an isolate scope that breaks the binding of currentTab)
    //if we use routing instead it will work fine
	$scope.select = function (nextTab) {
		$scope.currentTab = nextTab;
        if ($scope.onChange) {
            $scope.onChange(nextTab);
        }
	};
});
