app.directive('gridItems', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/gridItems.html',
        controller: 'gridItemsController',
        scope: {
            model: '=',
            editing: '=',
            type: '@',
            label: '@'
        }
    }
});

app.controller('gridItemsController', function($scope, $timeout, smoothScroll, colorsFactory, objectUtils, listUtils, formUtils) {
    // initialize variables
    $scope.colorOptions = colorsFactory.getColors();

    // inherited functions
    $scope.isEmpty = objectUtils.isEmptyArray;
    $scope.removeGroup = listUtils.removeGroup;
    $scope.focusText = formUtils.focusText;

    // when the user wants to view details on an item emit a toggleDetailsModal
    // event for the parent controller to handle
    $scope.viewDetails = function(item) {
        $scope.$emit('toggleDetailsModal', {visible: true, item: item});
    };

    // when the user wants to remove an item emit a removeItem event for the parent
    // controller to handle and respond to with an updateItems event when done
    $scope.removeItem = function(item) {
        $scope.$emit('removeItem', item);
    };

    // when the user moves an item splice the original out of the array it was in,
    // update item grouping and indexes, and emit a itemMoved event
    $scope.itemMoved = function(array, index) {
        array.splice(index, 1);
        listUtils.updateItems($scope.model);
        $scope.$emit('itemMoved');
    };

    $scope.scrollToItem = function(item) {
        var destElement = document.getElementsByTagName('grid-item')[item.index - 1];
        smoothScroll(destElement, {duration: 300, offset: window.innerHeight / 3});
    };

    $scope.focusItemIndex = function(item) {
        var indexElement = document.getElementsByClassName('item-index')[item.index - 1];
        indexElement.firstElementChild.focus();
    };

    $scope.applyIndex = function(item, skipScroll) {
        var success = listUtils.moveItemToNewIndex($scope.model, "mod", item);
        if (!success) return;
        listUtils.updateItems($scope.model);
        $scope.$emit('itemMoved');
        if (skipScroll) return;
        $timeout(function() {
            $scope.scrollToItem(item);
            $scope.focusItemIndex(item);
        });
    };

    $scope.resetIndex = function(item) {
        item.index = listUtils.actualIndex($scope.model, item);
    };

    $scope.indexKeyDown = function($event, item) {
        var key = $event.keyCode;
        if (key == 13) {
            $scope.applyIndex(item, $event.shiftKey);
            $event.preventDefault();
            $event.stopPropagation();
        }
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