app.directive('tableResults', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/tableResults.html',
        controller: 'tableResultsController',
        scope: {
            label: '@',
            message: '@',
            data: '=',
            columns: '=?',
            columnGroups: '=?',
            availableColumnData: '=?',
            sort: '=?',
            actions: '=?'
        }
    }
});

app.controller('tableResultsController', function($scope, $rootScope, tableUtils, objectUtils) {
    // inherit rootScope variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // inherit scope attributes
    angular.inherit($scope, 'columns');
    angular.inherit($scope, 'columnGroups');
    angular.inherit($scope, 'availableColumnData');
    angular.inherit($scope, 'sort');
    angular.inherit($scope, 'actions');
    angular.inherit($scope, 'permissions');

    // default scope attributes
    var defaultMessage = 'No ' + $scope.label + ' were found matching your search criteria.';
    angular.default($scope, 'message', defaultMessage);

    // initialize variables
    tableUtils.buildColumnClasses($scope.columns, 'main-cell');
    $scope.showModal = false;
    var sortedColumn;

    // inherited functions
    $scope.columnValue = tableUtils.columnValue;
    $scope.groupColumns = tableUtils.groupColumns;
    $scope.filterClass = tableUtils.filterClass;

    // toggles the visibility of the edit columns modal
    $scope.toggleModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showModal = visible;
    };

    // this function resolves a variable as a function if it is one,
    // else returns its value
    $scope.resolve = function(attribute, item, context) {
        if (typeof attribute === 'function') {
            return attribute($scope, item, context);
        } else {
            return attribute;
        }
    };

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

    // this function will toggle sorting for an input column between
    // up, down, and no sorting
    $scope.toggleSort = function(column) {
        var firstKey = column.invertSort ? "up" : "down";
        var secondKey = column.invertSort ? "down" : "up";
        var b1 = column[firstKey], b2 = column[secondKey];
        column[secondKey] = b1;
        column[firstKey] = !b1 && !b2;
    };

    // sorts by a column
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

    // load sort into view
    if ($scope.columns && $scope.sort && $scope.sort.column) {
        $scope.loadSort();
    }

    $scope.buildItemData = function() {
        $scope.builtItemData = true;
        $scope.data.forEach(function(item) {
            tableUtils.buildItemData(item, $scope.columns, $scope.resolve);
        });
    };

    $scope.$watch('data', function() {
        if (!$scope.data) return;
        $scope.buildItemData();
    }, true);
});