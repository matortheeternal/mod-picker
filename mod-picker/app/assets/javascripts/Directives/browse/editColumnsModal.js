app.directive('editColumnsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/editColumnsModal.html',
        scope: false,
        controller: 'editColumnsModalController'
    };
});

app.controller('editColumnsModalController', function($scope, formUtils) {
    $scope.unfocusEditColumnsModal = formUtils.unfocusModal($scope.toggleModal);
});
