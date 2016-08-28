app.directive('modDetailsModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modDetailsModal.html',
        controller: 'modDetailsModalController',
        scope: false
    };
});

app.controller('modDetailsModalController', function ($scope, $rootScope, modService, errorService) {
    // display error messages
    $scope.$on('modalErrorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response);
        errors.forEach(function(error) {
            $scope.$broadcast('modalMessage', error);
        });
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display success message
    $scope.$on('modalSuccessMessage', function(event, text) {
        var successMessage = {type: "success", text: text};
        $scope.$broadcast('modalMessage', successMessage);
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    $scope.toggleOption = function(option) {
        option.active = !option.active;
        $rootScope.$broadcast(option.active ? 'modOptionAdded' : 'modOptionRemoved', option.id);
    };
});
