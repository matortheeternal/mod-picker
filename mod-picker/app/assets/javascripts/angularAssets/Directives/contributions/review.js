app.directive('review', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/review.html',
        scope: {
            review: '=',
            index: '=',
            edit: '=?',
            showUserColumn: '=?',
            showMod: '=?'
        },
        controller: 'reviewController'
    };
});

app.controller('reviewController', function($scope, $rootScope) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
});