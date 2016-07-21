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

app.controller('gridItemsController', function($scope, colorsFactory) {
    $scope.colorOptions = colorsFactory.getColors();

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
});