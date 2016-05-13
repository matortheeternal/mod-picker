/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('review', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/review.html',
        controller: 'reviewController',
        scope: {
            review: '=',
            showAuthorColumn: '=?'
        }
    };
});

app.controller('reviewController', function ($scope) {
    $scope.helpfulMark = function(helpful) {
        if ($scope.review.helpful == helpful) {
            delete $scope.review.helpful;
        } else {
            $scope.review.helpful = helpful;
        }
    };
});
