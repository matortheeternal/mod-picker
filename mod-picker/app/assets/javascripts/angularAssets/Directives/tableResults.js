app.directive('tableResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tableResults.html',
        controller: 'tableResultsController',
        scope: {
            label: '@',
            data: '=',
            columns: '=',
            columnGroups: '=',
            availableColumnData: '=?',
            sort: '=?',
            actions: '=?'
        }
    }
});

app.controller('tableResultsController', function($scope, tableUtils) {
    // initialize variables
    $scope.permissions = $scope.$parent.permissions;
    var sortedColumn;

    // inherited functions
    $scope.columnValue = tableUtils.columnValue;
    $scope.groupColumns = tableUtils.groupColumns;
    $scope.filterClass = tableUtils.filterClass;

    // this function resolves a variable as a function if it is one,
    // else returns its value
    $scope.resolve = function(attribute, item, context) {
        if (typeof attribute === 'function') {
            return attribute($scope, item, context);
        } else {
            return attribute;
        }
    };

    // this function will toggle sorting for an input column between
    // up, down, and no sorting
    $scope.sortColumn = function(column) {
        // return if we don't have a sort object
        if (!$scope.sort) return;

        if(sortedColumn && sortedColumn !== column) {
            sortedColumn.up = false;
            sortedColumn.down = false;
        }
        sortedColumn = column;

        if (column.up) {
            column.up = false;
            column.down = true;
        } else if (column.down) {
            column.down = false;
        } else {
            column.up = true;
        }

        // send data to backend
        if (column.up || column.down) {
            $scope.sort.column = column.data;
            $scope.sort.direction = column.up ? "asc" : "desc";
        } else {
            delete $scope.sort.column;
            delete $scope.sort.direction;
        }
    };
});