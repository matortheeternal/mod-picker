app.directive('pluginDetailsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/pluginDetailsModal.html',
        controller: 'pluginDetailsModalController',
        scope: false
    };
});

app.controller('pluginDetailsModalController', function($scope, eventHandlerFactory) {
    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);
});
