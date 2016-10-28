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
});
