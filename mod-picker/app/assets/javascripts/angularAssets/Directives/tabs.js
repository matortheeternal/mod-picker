/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('tabs', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tabs.html',
        controller: 'tabsController',
        scope: {
            tabs: '='
        }
    };
});
app.controller('tabsController', function($scope, $state, $stickyState, $timeout) {
    $scope.findTab = function(tabName) {
        var index = $scope.tabs.findIndex(function(tab) {
            return tab.name === tabName;
        });
        return $scope.tabs[index];
    };

    $scope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
        var oldTabName = fromState.name.split(".").find(function(stateName) {
            return $scope.findTab(stateName);
        });
        var oldTab = $scope.findTab(oldTabName);
        if (oldTab) {
            oldTab.params = fromParams;
        }
    });
});
