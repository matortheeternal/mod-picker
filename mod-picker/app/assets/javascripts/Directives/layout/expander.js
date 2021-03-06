app.directive('expander', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/layout/expander.html',
        controller: 'expanderController',
        scope: {
            key: '@',
            expanded: '='
        }
    }
});

app.controller('expanderController', function($scope) {
    // default scope attributes
    angular.default($scope, 'expanded', {});

    // set expanded.key to 0
    $scope.expanded[$scope.key] = 0;

    // function to toggle expansion
    $scope.toggleExpanded = function() {
        $scope.expanded[$scope.key] ^= 1;
        if ($scope.expanded[$scope.key]) {
            $scope.$parent.$broadcast('rerenderSliders');
        }
    };
});