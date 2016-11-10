app.directive('modDetailsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modDetailsModal.html',
        controller: 'modDetailsModalController',
        scope: false
    };
});

app.controller('modDetailsModalController', function($scope, $rootScope, eventHandlerFactory, columnsFactory, sortUtils, tableUtils, formUtils) {
    // inherited functions
    $scope.unfocusModDetailsModal = formUtils.unfocusModal($scope.toggleDetailsModal);

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    // initialize variables
    $scope.columns = columnsFactory.modListModDetailsColumns();

    $scope.sort = {
        column: '',
        direction: 'ASC'
    };

    // expose service function to be usable in html 
    $scope.sortColumn = tableUtils.sortColumn;

    $scope.findModOption = function(optionId) {
        var optionsArray = $scope.detailsItem.mod_list_mod_options;
        return optionsArray.find(function(option) {
            return !option._destroy && option.mod_option_id == optionId;
        });
    };

    $scope.addModOption = function(optionId) {
        var existingModOption = $scope.findModOption(optionId);
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
        $rootScope.$broadcast(option.active ? 'modOptionAdded' : 'modOptionRemoved', option);
        if (option.active) {
            $scope.addModOption(option.id);
        } else {
            $scope.removeModOption(option.id);
        }
    };

    // load sort into view
    if ($scope.columns && $scope.sort && $scope.sort.column) {
        sortUtils.loadSort($scope.columns, $scope.sortedColumn, $scope.sort);
    }

    // load option active states
    if ($scope.detailsItem.mod) {
        var modOptions = $scope.detailsItem.mod.mod_options;
        modOptions.forEach(function(option) {
            var existingModOption = $scope.findModOption(option.id);
            option.active = !!existingModOption;
        });
    }
});
