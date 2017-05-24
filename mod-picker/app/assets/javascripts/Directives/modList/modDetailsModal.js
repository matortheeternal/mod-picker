app.directive('modDetailsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modDetailsModal.html',
        controller: 'modDetailsModalController',
        scope: false
    };
});

app.controller('modDetailsModalController', function($scope, $rootScope, eventHandlerFactory, formUtils, modOptionUtils) {
    // helper variables
    var mod = $scope.detailsItem.mod;

    // inherited functions
    $scope.unfocusModDetailsModal = formUtils.unfocusModal($scope.toggleDetailsModal);

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    $scope.$on('toggleOption', function(event, option) {
        $rootScope.$broadcast(option.active ? 'modOptionAdded' : 'modOptionRemoved', option);
        if (option.active) {
            $scope.addModOption($scope.detailsItem, option.id);
        } else {
            $scope.removeModOption($scope.detailsItem, option.id);
        }
    });

    // load option active states
    if (mod) {
        var modOptions = mod.mod_options;
        modOptions.forEach(function(option) {
            var existingModOption = $scope.findExistingModOption($scope.detailsItem, option.id);
            option.active = !!existingModOption;
        });
        if (!mod.nestedOptions) {
            mod.nestedOptions = modOptionUtils.getNestedModOptions(modOptions);
        }
    }
});
