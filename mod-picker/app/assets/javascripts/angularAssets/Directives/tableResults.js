app.directive('tableResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tableResults.html',
        controller: 'tableResultsController',
        scope: false
    }
});

app.controller('tableResultsController', function($scope) {

    // TODO: Less ugly pleease
    $scope.deepValue = deepValue;

    var sortedColumn;
    $scope.sortColumn = function(index) {
        //TODO: rewrite this
        var column = $scope.columns[index];

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
    }
});

app.filter('picker', function($filter) {
    return function() {
        var filterName = [].splice.call(arguments, 1, 1)[0];
        if (!filterName) {
            return arguments[0];
        }
        else {
            return $filter(filterName).apply(null, arguments);
        }
    };
});