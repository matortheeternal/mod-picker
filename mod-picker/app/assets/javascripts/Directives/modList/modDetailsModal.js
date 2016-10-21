app.directive('modDetailsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modDetailsModal.html',
        controller: 'modDetailsModalController',
        scope: false
    };
});

app.controller('modDetailsModalController', function($scope, $rootScope, eventHandlerFactory, columnsFactory) {
    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);


    // initialize variables
    $scope.columns = columnsFactory.modListModDetailsColumns();

    var sortedColumn;

    $scope.sort = {
        column: '',
        direction: 'ASC'
    }

    // load sort into view
    $scope.loadSort = function() {
        $scope.columns.forEach(function(column) {
            if ($scope.getSortData(column) === $scope.sort.column) {
                var sortKey = $scope.sort.direction === "ASC" ? "up" : "down";
                column[sortKey] = true;
                sortedColumn = column;
            }
        });
    };

    // get the sort data key for a column
    $scope.getSortData = function(column) {
        return column.sortData || (typeof column.data === "string" ? column.data : objectUtils.csv(column.data));
    };

    // sorts by column
    $scope.sortColumn = function(column) {
        // return if we don't have a sort object or the column isn't sortable
        if (!$scope.sort || column.unsortable) return;

        if (sortedColumn && sortedColumn !== column) {
            sortedColumn.up = false;
            sortedColumn.down = false;
        }
        sortedColumn = column;
        $scope.toggleSort(column);

        // send data to backend
        if (column.up || column.down) {
            $scope.sort.column = $scope.getSortData(column);
            $scope.sort.direction = column.up ? "ASC" : "DESC";
        } else {
            delete $scope.sort.column;
            delete $scope.sort.direction;
        }
    };

    // this function will toggle sorting for an input column between
    // up, down, and no sorting
    $scope.toggleSort = function(column) {
        var firstKey = column.invertSort ? "up" : "down";
        var secondKey = column.invertSort ? "down" : "up";
        var b1 = column[firstKey], b2 = column[secondKey];
        column[secondKey] = b1;
        column[firstKey] = !b1 && !b2;
    };

    // load sort into view
    if ($scope.columns && $scope.sort && $scope.sort.column) {
        $scope.loadSort();
    }

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

    // load option active states
    if ($scope.detailsItem.mod) {
        var modOptions = $scope.detailsItem.mod.mod_options;
        modOptions.forEach(function(option) {
            var existingModOption = $scope.findModOption(option.id);
            option.active = !!existingModOption;
        });
    }
});
