app.directive('modOptionTree', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/modOptionTree.html',
        scope: {
            modOptions: '='
        },
        controller: 'modOptionTreeController'
    }
});

app.controller('modOptionTreeController', function($scope) {
    $scope.toggleModOption = function(option) {
        // recurse into children
        option.children && option.children.forEach(function(child) {
            if (child.active && !option.active) {
                $scope.toggleModOption(child);
            }
        });
        // emit message
        $scope.$emit('toggleModOption', option);
    };
});