app.directive('comment', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/comment.html',
        controller: 'commentController',
        scope: {
            comment: '='
        }
    };
});

app.controller('commentController', function ($scope) {
});
