app.directive('tableItems', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tableItems.html',
        controller: 'tableItemsController',
        scope: {
            model: '=',
            editing: '=',
            columns: '=',
            removeCallback: '=',
            type: '@'
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
});