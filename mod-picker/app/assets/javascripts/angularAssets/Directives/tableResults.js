app.directive('tableResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tableResults.html',
        controller: 'tableResultsController',
        scope: {
            label: '@',
            data: '=',
            columns: '=',
            sort: '=',
            columnGroups: '=',
            availableColumnData: '=',
            actions: '=?'
        }
    }
});

app.controller('tableResultsController', function($scope, tableUtils) {
    var sortedColumn;

    // inherited functions
    $scope.columnValue = tableUtils.columnValue;
    $scope.groupColumns = tableUtils.groupColumns;

    // this function will toggle sorting for an input column between
    // up, down, and no sorting
    $scope.sortColumn = function(column) {
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