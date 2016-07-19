app.directive('modItems', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modItems.html',
        controller: 'modItemsController',
        scope: {
            mods: '=',
            editing: '=',
            removeCallback: '=',
            tools: '=?'
        }
    }
});

app.controller('modItemsController', function($scope) {
    $scope.updateIndexes = function() {
        for (var i = 0; i < $scope.mods.length; i++) {
            $scope.mods[i].index = i + 1;
        }
    };

    $scope.modMoved = function(index) {
        $scope.mods.splice(index, 1);
        $scope.updateIndexes();
    };
});