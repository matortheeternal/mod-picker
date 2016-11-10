app.directive('requirementsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/requirementsModal.html',
        scope: false,
        controller: 'requirementsModalController'
    };
});

app.controller('requirementsModalController', function($scope, formUtils) {
    $scope.unfocusRequirementsModal = formUtils.unfocusModal($scope.toggleRequirementsModal);
});
