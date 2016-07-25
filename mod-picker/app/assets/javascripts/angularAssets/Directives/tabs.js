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
app.controller('tabsController', function($scope, $state, $stickyState) {
    $scope.findTab = function(tabName) {
        var index = $scope.tabs.findIndex(function(tab) {
            return tab.name === tabName;
        });
        return $scope.tabs[index];
    };

    $scope.isCurrentTab = function(tabName) {
        if ($state.includes('**.' + tabName)) {
            return 'selected-tab';
        } else {
            return '';
        }
    };

    $scope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
        var oldTab = $scope.findTab(fromState.name.slice(9));
        if(oldTab) {
            oldTab.params = fromParams;
        }
    });
});
