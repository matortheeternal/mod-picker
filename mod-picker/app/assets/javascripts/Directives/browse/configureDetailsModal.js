app.directive('configureDetailsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/configureDetailsModal.html',
        scope: false,
        controller: 'configureDetailsModalController'
    };
});

app.controller('configureDetailsModalController', function($scope, formUtils) {
    $scope.unfocusDetailsModal = formUtils.unfocusModal($scope.toggleModal);
});
