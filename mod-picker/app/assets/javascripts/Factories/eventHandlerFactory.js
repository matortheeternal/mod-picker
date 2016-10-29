app.service('eventHandlerFactory', function(errorService) {
    this.buildMessageHandlers = function($scope, allowCustomMessages) {
        // display error messages
        $scope.$on('errorMessage', function(event, params) {
            var resourceId = $scope.mod && $scope.mod.id;
            var errors = errorService.errorMessages(params.label, params.response, resourceId);
            errors.forEach(function(error) {
                $scope.$broadcast('message', error);
            });
            // stop event propagation - we handled it
            event.stopPropagation();
        });

        // display success message
        $scope.$on('successMessage', function(event, text) {
            var successMessage = { type: "success", text: text };
            $scope.$broadcast('message', successMessage);
            // stop event propagation - we handled it
            event.stopPropagation();
        });

        if (allowCustomMessages) {
            // display custom message
            $scope.$on('customMessage', function(event, message) {
                $scope.$broadcast('message', message);
                // stop event propagation - we handled it
                event.stopPropagation();
            });
        }
    };

    this.buildModalMessageHandlers = function($scope, allowCustomMessages) {
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

        if (allowCustomMessages) {
            // display custom message
            $scope.$on('modalCustomMessage', function(event, message) {
                $scope.$broadcast('modalMessage', message);
                // stop event propagation - we handled it
                event.stopPropagation();
            });
        }
    }
});