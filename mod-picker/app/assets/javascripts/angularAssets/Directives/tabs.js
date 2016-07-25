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
        $scope.findTab(oldTabName).params = fromParams;
    });

    $scope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
        // TODO: this is (probably) a temporary fix for a really really weird bug that I can't figure out.
        // reproduction: comment this out. Go to the mod page(review tab). Click add review. go to the compatibility tab. change the sorting. Go back to the review tab.
        $timeout(function() {
            if (!$state.is(toState)) {
                $state.go(toState.name, toParams);
            }
        }, 1);
    });
});
