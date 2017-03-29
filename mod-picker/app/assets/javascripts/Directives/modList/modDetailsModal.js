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

    $scope.toggleOption = function(option) {
        $rootScope.$broadcast(option.active ? 'modOptionAdded' : 'modOptionRemoved', option);
        if (option.active) {
            $scope.addModOption($scope.detailsItem, option.id);
        } else {
            $scope.removeModOption($scope.detailsItem, option.id);
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
            var existingModOption = $scope.findExistingModOption($scope.detailsItem, option.id);
            option.active = !!existingModOption;
        });
    }
});
