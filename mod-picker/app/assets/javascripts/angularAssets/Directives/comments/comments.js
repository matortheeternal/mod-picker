app.directive('comments', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/comments/comments.html',
        scope: {
            comments: '=',
            currentUser: '=',
            index: '='
        }
    };
});