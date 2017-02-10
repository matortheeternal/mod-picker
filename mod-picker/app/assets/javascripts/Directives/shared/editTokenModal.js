app.directive('editTokenModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/editTokenModal.html',
        controller: 'editTokenModalController',
        scope: false
    }
});

app.controller('editTokenModalController', function($scope, apiTokenService, formUtils, eventHandlerFactory) {
    // inherited functions
    $scope.unfocusTokenModal = formUtils.unfocusModal($scope.toggleTokenModal);

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    $scope.saveToken = function() {
        apiTokenService.updateToken($scope.activeToken).then(function() {
            $scope.$emit('modalSuccessMessage', 'Updated API Token "' + $scope.activeToken.name + '"successfully');
            $scope.$applyAsync(function() {
                $scope.originalToken.name = $scope.activeToken.name;
            });
        }, function(response) {
            var params = {
                text: 'Error updating API token: '+$scope.activeToken.name,
                response: response
            };
            $scope.$emit('modalErrorMessage', params);
        });
    };
});
