app.service('tableUtils', function($filter, objectUtils, sortUtils) {
    var service = this;

    // sanitizes a filter to be a class by removing any filter params
    this.filterClass = function(filter) {
        if (filter) {
            if (filter.indexOf(':') > -1) {
                return filter.split(':')[0] + '-cell';
            } else {
                return filter + '-cell';
            }
        } else {
            return 'text-cell';
        }
    };

    this.buildColumnClasses = function(columns, firstColumnClass) {
        columns.forEach(function(column, index) {
            column.fullClass = '';
            if (column.class) {
                column.fullClass += column.class;
            }
            column.fullClass += ' ' + service.filterClass(column.filter);
            if (index == 0 && firstColumnClass) {
                column.fullClass += ' ' + firstColumnClass;
            }
        });
    };

    // this function resolves a variable as a function if it is one,
    // else returns its value
    this.resolve = function($scope) {
        return function(attribute, item, context) {
            if (typeof attribute === 'function') {
                return attribute($scope, item, context);
            } else {
                return attribute;
            }
        };
    };

    // this function uses objectUtils.deepValue to retrieve the value
    // of a data item based on the data path described in the column's
    // data property.  if the data property has multiple paths it will
    // test them sequentially until it finds a non-null value.
    this.columnValue = function(item, data) {
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

    this.buildItemData = function(item, columns, resolve, key) {
        var pickerFilter = $filter('picker');
        item[key] = [];
        columns.forEach(function(column) {
            var columnValue = service.columnValue(item, column.data);
            if (column.filter) columnValue = pickerFilter(columnValue, column.filter);
            var columnData = { data: columnValue };
            if (column.note) columnData.note = resolve(column.note, item);
            if (column.link) columnData.link = column.link(item);
            if (column.image) columnData.image = column.image(item);
            item[key].push(columnData);
        });
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
        var dataType = typeof data;
        // if the data property of the column is a string or a function the
        // column should always be present.  also, if availableColumnData is
        // undefined assume all columns are available
        if (dataType === 'string' || dataType === 'function' || !availableColumnData) {
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

    // sorts by column
    this.sortColumn = function(column, sort, sortedColumn) {
        // return if we don't have a sort object or the column isn't sortable
        if (!sort || column.unsortable) return;

        if (sortedColumn && sortedColumn !== column) {
            sortedColumn.up = false;
            sortedColumn.down = false;
        }
        sortedColumn = column;
        service.toggleSort(column);

        // send data to backend
        if (column.up || column.down) {
            sort.column = sortUtils.getSortData(column);
            sort.direction = column.up ? "ASC" : "DESC";
        } else {
            delete sort.column;
            delete sort.direction;
        }
    };

    // this function will toggle sorting for an input column between
    // up, down, and no sorting
    this.toggleSort = function(column) {
        var firstKey = column.invertSort ? "up" : "down";
        var secondKey = column.invertSort ? "down" : "up";
        var b1 = column[firstKey], b2 = column[secondKey];
        column[secondKey] = b1;
        column[firstKey] = !b1 && !b2;
    };
});