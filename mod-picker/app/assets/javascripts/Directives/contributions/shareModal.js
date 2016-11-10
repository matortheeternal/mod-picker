app.directive('shareModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/shareModal.html',
        scope: false,
        controller: 'shareModalController'
    };
});

app.controller('shareModalController', function($scope, formUtils) {
    $scope.unfocusShareModal = formUtils.unfocusModal($scope.toggleShareModal);
});
