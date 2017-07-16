app.directive('modListAuthorsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modListAuthorsModal.html',
        scope: false,
        controller: 'modListAuthorsModalController'
    };
});

app.controller('modListAuthorsModalController', function($scope, formUtils) {
    $scope.unfocusAuthorsModal = formUtils.unfocusModal($scope.toggleAuthorsModal);
});
