app.directive('sortControl', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/sortControl.html',
        // controller: 'sortController',
        scope: {
            column: '=',
            direction: '=',
            retrieveCallback: '&',
            sortOptions: '='
        }
    }
});
//
// app.controller('sortController', function($scope) {
//     if (!angular.isDefined($scope.sort)) {
//         $scope.sort = $scope.$parent.sort;
//     }
//     if (!angular.isDefined($scope.sortOptions)) {
//         $scope.sortOptions = $scope.$parent.sortOptions;
//     }
// });
