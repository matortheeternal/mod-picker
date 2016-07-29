app.service('tableUtils', function (objectUtils) {
    var service = this;

    // this function resolves a variable as a function if it is one,
    // else returns its value
    this.resolveAttribute = function(attribute, item) {
        if (typeof attribute === 'function') {
            return attribute(item);
        } else {
            return attribute;
        }
    };

    // this function uses objectUtils.deepValue to retrieve the value
    // of a data item based on the data path described in the column's
    // data property.  if the data property has multiple paths it will
    // test them sequentially until it finds a non-null value.
    this.columnValue = function (item, data) {
        // a lot of the time the data property of the column is just
        // a string denoting the path to look at in the item to find
        // the value we want to display
        if (typeof data === 'string' || data instanceof String) {
            return objectUtils.deepValue(item, data);
        }
        // sometimes it's a function because it needs to do something
        // more complex than just display a single value from the item
        else if (typeof data === 'function') {
            return data(item);
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

    // this function returns the number of columns visible (plus 1 for the
    // actions column)
    this.getNumCols = function(columns) {
        var i = 1;
        columns.forEach(function(column) {
            if (column.visibility) i++;
        });
        return i;
    };

    // this function returns a subset of @columns with group properties
    // matching @groupName.  Also excludes columns that are not available
    // or are required
    this.groupColumns = function(availableColumnData, columns, groupName) {
        return Array.prototype.filter.call(columns, function(column) {
            return (column.group === groupName) && !column.required &&
                service.columnAvailable(availableColumnData, column);
        });

    };

    // this function accesses the $scope.availableColumnData variable to see
    // whether or not a column should be visible to the user
    this.columnAvailable = function(availableColumnData, column) {
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
                    if (availableColumnData.indexOf(property) > -1) {
                        return true;
                    }
                }
            }
            return false;
        }
    };
});