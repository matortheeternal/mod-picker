app.directive('sortControl', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/sortControl.html',
        controller: 'sortController',
        scope: {
            sort: '=?',
            sortOptions: '=?',
            dynamic: '@'
        }
    }
});

app.controller('sortController', function($scope) {
    // inherited scope attributes
    angular.inherit($scope, 'sort');
    angular.inherit($scope, 'sortOptions');

    if ($scope.dynamic) {
        $scope.$parent.$watch('sortOptions', function() {
            $scope.sortOptions = $scope.$parent.sortOptions;
            var currentSortOption = $scope.sortOptions.find(function(sortOption) {
                return sortOption.value === $scope.sort.column;
            });
            if (!currentSortOption) {
                $scope.sort.column = $scope.sortOptions[0].value;
            }
        });
    }
});
