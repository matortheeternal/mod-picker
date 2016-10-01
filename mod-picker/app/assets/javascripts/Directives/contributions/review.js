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
            showMarks: '=?'
        },
        controller: 'reviewController'
    };
});

app.controller('reviewController', function($scope, $rootScope) {
    // set defaults
    angular.default($scope, 'showUserColumn', true);
    angular.default($scope, 'showMarks', true);
    angular.default($scope, 'showMod', false);

    // inherited variables
    $scope.currentUser = $rootScope.currentUser;

});
