/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('review', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notes/review.html',
        controller: 'reviewController',
        scope: {
            review: '=',
            showAuthorColumn: '=?'
        }
    };
});

app.controller('reviewController', function ($scope, modService) {
    $scope.helpfulMark = function(helpful) {
        if ($scope.review.helpful == helpful) {
            modService.helpfulMark("reviews", $scope.review.id).then(function (data) {
                if (data.status == "ok") {
                    delete $scope.review.helpful;
                }
            });
        } else {
            modService.helpfulMark("reviews", $scope.review.id, helpful).then(function (data) {
                if (data.status == "ok") {
                    $scope.review.helpful = helpful;
                }
            });
        }
    };
});
