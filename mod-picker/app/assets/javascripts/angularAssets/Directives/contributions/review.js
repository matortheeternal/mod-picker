/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('review', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/review.html',
        scope: {
            review: '=',
            index: '=',
            currentUser: '=',
            edit: '=?',
            showUserColumn: '=?',
            showMod: '=?'
        }
    };
});
