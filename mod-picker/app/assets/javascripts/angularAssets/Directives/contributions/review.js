/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('review', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/review.html',
        controller: 'reviewController',
        scope: {
            review: '=',
            index: '=',
            currentUser: '=',
            edit: '=?',
            showUserColumn: '=?',
            showMod: '=?',
            showActions: '=?'
        }
    };
});

app.controller('reviewController', function ($scope) {
    // set defaults to true if not defined
    $scope.showUserColumn = angular.isDefined($scope.showUserColumn) ? $scope.showUserColumn : true;
    $scope.showActions = angular.isDefined($scope.showActions) ? $scope.showActions : true;
    $scope.showMod = angular.isDefined($scope.showMod) ? $scope.showMod : true;

});
