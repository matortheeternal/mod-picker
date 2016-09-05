app.directive('pluginDetailsModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/pluginDetailsModal.html',
        controller: 'pluginDetailsModalController',
        scope: false
    };
});

app.controller('pluginDetailsModalController', function ($scope, pluginService, errorService) {
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
});
