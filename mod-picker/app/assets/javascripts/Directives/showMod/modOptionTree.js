app.directive('modOptionTree', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/modOptionTree.html',
        scope: {
            modOptions: '=',
            disable: '=?'
        },
        controller: 'modOptionTreeController'
    }
});

app.controller('modOptionTreeController', function($scope) {
    angular.default($scope, 'disable', false);

    $scope.toggleModOption = function(option) {
        if ($scope.disable) return;
        // recurse into children
        option.children && option.children.forEach(function(child) {
            if (child.active && !option.active) {
                child.active = false;
            }
        });
        // emit message
        $scope.$emit('toggleModOption', option);
    };

    $scope.toggleExpansion = function(option) {
        option.expanded = !option.expanded;
    }
});
