app.directive('authorsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/authorsModal.html',
        scope: false,
        controller: 'authorsModalController'
    };
});

app.controller('authorsModalController', function($scope, formUtils) {
    // inherited functions
    $scope.unfocusAuthorsModal = formUtils.unfocusModal($scope.toggleAuthorsModal);

    // initialize variables
    $scope.canCreateCuratorRequest = $scope.currentUser.reputation.overall > 20;
    if ($scope.canCreateCuratorRequest) {
        $scope.curatorRequestTitle = 'Click here if you would like to curate this mod.';
    } else {
        $scope.curatorRequestTitle = 'You do not have enough reputation to submit a curator request for \nthis mod.';
    }
});
