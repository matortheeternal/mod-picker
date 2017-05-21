app.directive('modOptionsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/modOptionsModal.html',
        scope: false,
        controller: 'modOptionsModalController'
    };
});

app.controller('modOptionsModalController', function($scope, formUtils) {
    $scope.unfocusModOptionsModal = formUtils.unfocusModal($scope.toggleModOptionsModal);
});
