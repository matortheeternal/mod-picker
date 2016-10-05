app.directive('userCard', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/userCard.html',
        scope: {
            user: '='
        },
        controller: 'userCardController'
    }
});

app.controller('userCardController', function($scope, $rootScope, moderationActionsFactory) {
    // inherited variables
    $scope.permissions = $rootScope.permissions;

    // shared function setup
    moderationActionsFactory.buildActions($scope);
});