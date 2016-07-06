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
    $scope.isCurrentTab = function(tabName) {
        if ($state.includes('**.' + tabName)) {
            return 'selected-tab';
        } else {
            return 'unselected-tab';
        }
    };

    $scope.goToState = function(stateName, params) {
        $state.go(stateName, params);
    };
});
