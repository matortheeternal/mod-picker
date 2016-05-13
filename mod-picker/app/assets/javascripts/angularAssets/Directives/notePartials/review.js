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
//leaving this here in case it is needed when the directive is actually made
});
