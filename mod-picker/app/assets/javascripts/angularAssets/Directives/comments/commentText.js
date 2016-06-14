app.directive('commentText', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/comments/commentText.html',
        scope: {
            comment: '='
        }
    };
});