app.service('tabUtils', function() {

    this.buildTabHelpers = function ($scope, $state, baseStateName, hasConditionalTabs) {
        var goToTab = function(tab) {
            var newState = 'base.' + baseStateName + '.' + tab.name;
            $state.go(newState, tab.params, {location: 'replace'});
        };

        var redirectToFirstTab = function() {
            goToTab($scope.tabs[0]);
        };

        var indexOfTab = function(tabName) {
            return tabIndex = $scope.tabs.findIndex(function(tab) {
                return tabName === tab.name;
            });
        };

        var tabIsPresent = function(tabName) {
            return (indexOfTab(tabName) != -1);
        };

        var currentTab = function() {
            var currentState = $state.current.name;
            var currentStateArray = currentState.split(".");
            return currentStateArray[currentStateArray.length - 1];
        };

        $scope.nextTab = function() {
            var nextIndex = (indexOfTab(currentTab()) + 1) % $scope.tabs.length;
            goToTab($scope.tabs[nextIndex]);
        };

        if (hasConditionalTabs) {
            // redirect to the first tab if changing to a non-present tab
            $scope.$on('$stateChangeSuccess', function(event, toState) {
                var toStateNameArray = toState.name.split(".");
                // if changing within the base state
                if (toStateNameArray[1] === baseStateName) {
                    // if changing to an unavailable tab
                    if (!tabIsPresent(currentTab())) {
                        redirectToFirstTab();
                    }
                }
            });
        }
    };
});