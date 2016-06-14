app.directive('comment', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/comments/comment.html',
        scope: {
            comment: '=',
            currentUser: '=',
            index: '='
        }
    };
});