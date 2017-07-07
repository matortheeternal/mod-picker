app.controller('userSettingsPremiumController', function($scope, $rootScope, $state, columnsFactory, actionsFactory) {
    // initialize variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.actions = actionsFactory.premiumActions();
    $scope.columns = columnsFactory.premiumColumns();
    $scope.columnGroups = columnsFactory.premiumColumnGroups();
    $scope.hasSubscriptions = $scope.user.premium_subscriptions.length > 0;
    $scope.user.premium_subscriptions.forEach(function(subscription) {
        if (!subscription.is_active) {
            $scope.previousSubscription = subscription;
        } else {
            $scope.activeSubscription = subscription;
        }
    });

    // methods
    $scope.getPremium = function() {
        $state.go("base.premium", {}, {notify: true});
    }
});