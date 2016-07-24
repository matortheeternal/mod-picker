app.directive('gridItems', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/gridItems.html',
        controller: 'gridItemsController',
        scope: {
            model: '=',
            editing: '=',
            removeCallback: '=',
            type: '@'
        }
    }
});

app.controller('gridItemsController', function($scope, $timeout, colorsFactory, objectUtils, listUtils) {
    // initialize variables
    $scope.colorOptions = colorsFactory.getColors();
    $scope.draggingGroup = false;
    $scope.isEmpty = objectUtils.isEmptyArray;

    $scope.updateItems = function() {
        var i = 1;
        $scope.model.forEach(function(item) {
            if (item.children) {
                item.index = i; // group indexing
                item.children.forEach(function(child) {
                    child.group_id = item.id;
                    child.index = i++;
                });
            } else {
                item.group_id = null;
                item.index = i++;
            }
        });
    };

    $scope.focusText = function($event) {
        $event.target.select();
    };

    $scope.moveItem = function(array, index) {
        array.splice(index, 1);
        $scope.updateItems();
        $scope.$emit('modMoved');
    };

    $scope.removeGroup = function(group, index) {
        // handle the group children
        group.children.forEach(function(child) {
            child.group_id = null;
            $scope.model.splice(index++, 0, child);
        });
        // destroy the group and clear its children
        group._destroy = true;
        group.children = [];
    };

    $scope.dragStart = function(item) {
        if (item.children) {
            $scope.draggingGroup = true;
        }
    };

    $scope.dragEnd = function() {
        $scope.draggingGroup = false;
    };

    $scope.$on('moveMod', function(event, options) {
        var params;
        var destMod = listUtils.findMod($scope.model, options.destId);

        // check if the destination mod is on the view model
        if (!destMod) {
            params = {type: 'error', text: 'Failed to move mod, could not find destination mod.' };
            $scope.$emit('customMessage', params);
            return;
        }

        // this splices the mod if found
        var moveMod = listUtils.findMod($scope.model, options.moveId, true);

        // check if the mod to be moved is on the view model
        if (!moveMod) {
            params = {type: 'error', text: 'Failed to move mod, could not find mod to move.' };
            $scope.$emit('customMessage', params);
            return;
        }

        var moveModel = $scope.model;
        // if both mods are in the same group, move within the group
        if (moveMod.group_id == destMod.group_id) {
            moveModel = listUtils.findGroup($scope.model, moveMod.group_id).children;
        }
        // send a cursor down the model until the index of the item we're on exceeds the destMod's index
        var newIndex = moveModel.findIndex(function(item) {
            return item.index >= destMod.index;
        });

        // reinsert the mod at the new index
        moveModel.splice(options.after ? newIndex + 1 : newIndex, 0, moveMod);

        // update item indexes and groups
        $scope.updateItems();
        $scope.$emit('modMoved');
    });
});