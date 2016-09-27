app.directive('modDetailsModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modDetailsModal.html',
        controller: 'modDetailsModalController',
        scope: false
    };
});

app.controller('modDetailsModalController', function ($scope, $rootScope, eventHandlerFactory) {
    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    $scope.toggleOption = function(option) {
        option.active = !option.active;
        $rootScope.$broadcast(option.active ? 'modOptionAdded' : 'modOptionRemoved', option.id);
    };
});
