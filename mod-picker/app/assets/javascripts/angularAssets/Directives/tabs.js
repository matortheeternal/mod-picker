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
    $scope.isCurrentTab = function(tabName) {
        if ($state.includes('**.' + tabName)) {
            return 'selected-tab';
        } else {
            return '';
        }
    };

    $scope.selectTab = function(tabName) {
        if ($state.includes('**.' + tabName)) {
            return;
        }

        var loadedTabState = $stickyState.getInactiveStates().find(function(state) {
            //an array of every state on the tree leading to this one, in order of parentage
            var stateArray = state.toString().split(".");
            return stateArray.find(function(stateName) {
                return tabName === stateName;
            });
        });

        if (loadedTabState) {
            var params = {};
            var setParams = loadedTabState.ownParams;
            for (var paramName in setParams) {
                if (!paramName.startsWith('$$') && !paramName.startsWith('_')) {
                    var value = setParams[paramName].value();
                    if (value) {
                        params[paramName] = value;
                    }
                }
            }
            $state.go('^.' + tabName, params);
        } else {
            $state.go('^.' + tabName);
        }
    };
});
