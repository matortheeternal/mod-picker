app.directive('tableItems', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/tableItems.html',
        controller: 'tableItemsController',
        scope: {
            model: '=',
            columns: '=',
            columnGroups: '=',
            actions: '=',
            editing: '=',
            startingIndex: '=?',
            type: '@',
            label: '@'
        }
    }
});

app.controller('tableItemsController', function($scope, $timeout, colorsFactory, objectUtils, listUtils, formUtils, tableUtils) {
    // initialize variables
    $scope.colorOptions = colorsFactory.getColors();
    $scope.draggingGroup = false;
    $scope.itemTemplateUrl = '/resources/directives/modList/tableItem.html';
    $scope.groupTemplateUrl = '/resources/directives/modList/tableGroup.html';
    tableUtils.buildColumnClasses($scope.columns);

    // inherited functions
    $scope.isEmpty = objectUtils.isEmptyArray;
    $scope.removeGroup = listUtils.removeGroup;
    $scope.focusText = formUtils.focusText;
    $scope.columnValue = tableUtils.columnValue;
    $scope.groupColumns = tableUtils.groupColumns;
    $scope.filterClass = tableUtils.filterClass;
    $scope.getNumCols = tableUtils.getNumCols;

    // toggles the visibility of the edit columns modal
    $scope.toggleModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showModal = visible;
    };

    // when the user wants to remove an item emit a removeItem event for the parent
    // controller to handle and respond to with an updateItems event when done
    $scope.removeItem = function(item) {
        $scope.$emit('removeItem', item);
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

    // when the user moves an item splice the original out of the array it was in,
    // update item grouping and indexes, and emit a itemMoved event
    $scope.itemMoved = function(array, index) {
        array.splice(index, 1);
        listUtils.updateItems($scope.model, $scope.startingIndex);
        $scope.$emit('itemMoved');
    };

    $scope.dragStart = function(item) {
        $scope.draggingGroup = !!item.children;
    };

    $scope.dragEnd = function() {
        $scope.draggingGroup = false;
    };

    $scope.buildItemData = function() {
        $scope.builtItemData = true;
        listUtils.forEachItem($scope.model, function(item) {
            tableUtils.buildItemData(item, $scope.columns, $scope.resolve, 'columnData');
        });
    };

    $scope.buildAttributes = function() {
        $scope.model.forEach(function(item) {
            if (item.children) {
                item.dragType = 'group';
                item.hasChildren = true;
                item.class = 'group bg-'+item.color;
                item.childrenEmpty = $scope.isEmpty(item.children);
                item.templateUrl = $scope.groupTemplateUrl;
            } else {
                item.dragType = 'item';
                item.templateUrl = $scope.itemTemplateUrl;
            }
        });
    };

    $scope.$on('moveItem', function(event, options) {
        var errorMessage = listUtils.moveItem($scope.model, $scope.type, options);
        if (errorMessage) {
            $scope.$emit('customMessage', { type: 'error', text: errorMessage });
        } else {
            // success: update item indexes and groups and emit an itemMoved event
            listUtils.updateItems($scope.model, $scope.startingIndex);
            $scope.$emit('itemMoved');
        }
    });

    $scope.$on('updateItems', function() {
        listUtils.updateItems($scope.model, $scope.startingIndex);
    });

    $scope.$watch('columns', function() {
        $scope.activeColumnsCount = $scope.getNumCols($scope.columns);
    }, true);

    $scope.$watch('model', function() {
        if (!$scope.model) return;
        $scope.modelEmpty = $scope.isEmpty($scope.model);
        $scope.buildAttributes();
        $scope.buildItemData();
    }, true);
});