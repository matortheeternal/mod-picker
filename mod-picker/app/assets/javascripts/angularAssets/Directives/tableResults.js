app.directive('tableResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tableResults.html',
        controller: 'tableResultsController',
        scope: false
    }
});

app.controller('tableResultsController', function($scope, objectUtils) {
    var sortedColumn;

    // this function will set toggle sorting for a selected column
    // index between up, down, and no sorting
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
    };

    // this function returns a subset of @columns with group properties
    // matching @groupName.  Also excludes columns that are not available
    // or are required
    $scope.groupColumns = function(columns, groupName) {
        return columns.filter(function(column) {
            return (column.group === groupName) && !column.required &&
                $scope.columnAvailable(column);
        });

    };

    // this function uses objectUtils.deppValue to retrieve the value
    // of a data item based on the data path described in the column's
    // data property.  if the data property has multiple paths it will
    // test them sequentially until it finds a non-null value.
    $scope.columnValue = function(item, data) {
        // a lot of the time the data property of the column is just
        // a string denoting the path to look at in the item to find
        // the value we want to display
        if (typeof data === 'string' || data instanceof String) {
            return objectUtils.deepValue(item, data);
        }
        // sometimes it's not.  sometimes the data property is an
        // object with an ordered set of keys to check on the item
        // (e.g. for different site statistics), which we need to
        // test in order until we can find a value for the column.
        else {
            var value;
            for (var property in data) {
                if (data.hasOwnProperty(property)) {
                    value = objectUtils.deepValue(item, data[property]);
                    if (value) {
                        return value;
                    }
                }
            }
            // if we couldn't find the value, return null explicitly to show
            // that we recognize this function can return null explicitly
            return null;
        }
    };

    // this function accesses the $scope.availableColumnData variable to see
    // whether or not a column should be visible to the user
    $scope.columnAvailable = function(column) {
        var data = column.data;
        // if the data property of the column is a raw string, thus column is
        // by definition always present, and should always be available.
        if (typeof data === 'string' || data instanceof String) {
            return true;
        }
        // else we need to check if one of the data property keys is contained
        // in the availableColumnData string array
        else {
            for (var property in data) {
                if (data.hasOwnProperty(property)) {
                    if ($scope.availableColumnData.indexOf(property) > -1) {
                        return true;
                    }
                }
            }
            return false;
        }
    };
});