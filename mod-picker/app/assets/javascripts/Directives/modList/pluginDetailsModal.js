app.directive('pluginDetailsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/pluginDetailsModal.html',
        controller: 'pluginDetailsModalController',
        scope: false
    };
});

app.controller('pluginDetailsModalController', function($scope, eventHandlerFactory, formUtils) {
    // inherited functions
    $scope.unfocusPluginDetailsModal = formUtils.unfocusModal($scope.toggleDetailsModal);

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);
});
