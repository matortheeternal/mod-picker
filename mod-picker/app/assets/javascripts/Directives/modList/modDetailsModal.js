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

    $scope.addModOption = function(optionId) {
        var optionsArray = $scope.detailsItem.mod_list_mod_options;
        var existingModOption = optionsArray.find(function(option) {
            return option.mod_option_id = optionId;
        });
        if (existingModOption) {
            if (existingModOption._destroy) {
                delete existingModOption._destroy;
            }
        } else {
            $scope.detailsItem.mod_list_mod_options.push({
                mod_option_id: optionId
            });
        }
    };

    $scope.removeModOption = function(optionId) {
        var optionsArray = $scope.detailsItem.mod_list_mod_options;
        var index = optionsArray.findIndex(function(option) {
            return option.mod_option_id == optionId;
        });
        if (index > -1) {
            optionsArray[index]._destroy = true;
        }
    };

    $scope.toggleOption = function(option) {
        $rootScope.$broadcast(option.active ? 'modOptionAdded' : 'modOptionRemoved', option.id);
        if (option.active) {
            $scope.addModOption(option.id);
        } else {
            $scope.removeModOption(option.id);
        }
    };
});
