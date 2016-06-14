app.directive('commentHeader', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/comments/commentHeader.html',
        scope: {
            comment: '='
        }
    };
});