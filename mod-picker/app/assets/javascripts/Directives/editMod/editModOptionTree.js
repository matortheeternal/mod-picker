app.directive('editModOptionTree', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/editModOptionTree.html',
        scope: {
            modOptions: '=',
            oldOptions: '=?'
        },
        controller: 'editModOptionTreeController'
    }
});

app.controller('editModOptionTreeController', function($scope) {
    $scope.toggleExpansion = function(option) {
        option.expanded = !option.expanded;
    }
});
