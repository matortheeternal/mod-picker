app.directive('tableItems', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tableItems.html',
        controller: 'tableItemsController',
        scope: {
            model: '=',
            columns: '=',
            columnGroups: '=',
            actions: '=',
            editing: '=',
            type: '@',
            label: '@'
        }
    }
});

app.controller('tableItemsController', function($scope, $timeout, colorsFactory, objectUtils, listUtils, formUtils, tableUtils) {
    // initialize variables
    $scope.colorOptions = colorsFactory.getColors();

    // inherited functions
    $scope.isEmpty = objectUtils.isEmptyArray;
    $scope.removeGroup = listUtils.removeGroup;
    $scope.focusText = formUtils.focusText;
    $scope.columnValue = tableUtils.columnValue;
    $scope.groupColumns = tableUtils.groupColumns;
    $scope.getNumCols = tableUtils.getNumCols;

    // when the user wants to remove an item emit a removeItem event for the parent
    // controller to handle and respond to with an updateItems event when done
    $scope.removeItem = function(item) {
        $scope.$emit('removeItem', item);
    };

    // execute an action on an item
    $scope.execute = function(action, item) {
        action.execute($scope, item);
    };

    // when the user moves an item splice the original out of the array it was in,
    // update item grouping and indexes, and emit a itemMoved event
    $scope.itemMoved = function(array, index) {
        array.splice(index, 1);
        listUtils.updateItems($scope.model);
        $scope.$emit('itemMoved');
    };

    $scope.$on('moveItem', function(event, options) {
        var errorMessage = listUtils.moveItem($scope.model, $scope.type, options);
        if (errorMessage) {
            $scope.$emit('customMessage', { type: 'error', text: errorMessage });
        } else {
            // success: update item indexes and groups and emit an itemMoved event
            listUtils.updateItems($scope.model);
            $scope.$emit('itemMoved');
        }
    });

    $scope.$on('updateItems', function() {
        listUtils.updateItems($scope.model);
    });
});