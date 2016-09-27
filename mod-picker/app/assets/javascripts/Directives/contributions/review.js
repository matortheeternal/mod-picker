app.directive('review', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/review.html',
        scope: {
            review: '=',
            index: '=',
            edit: '=?',
            showUserColumn: '=?',
            showMod: '=?',
            showActions: '=?'
        },
        controller: 'reviewController'
    };
});

app.controller('reviewController', function($scope, $rootScope) {
    // set defaults to true if not defined
    $scope.showUserColumn = angular.isDefined($scope.showUserColumn) ? $scope.showUserColumn : true;
    $scope.showActions = angular.isDefined($scope.showActions) ? $scope.showActions : true;
    $scope.showMod = angular.isDefined($scope.showMod) ? $scope.showMod : true;

    // inherited variables
    $scope.currentUser = $rootScope.currentUser;

});
