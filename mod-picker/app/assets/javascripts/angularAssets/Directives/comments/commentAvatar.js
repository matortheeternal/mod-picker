app.directive('commentAvatar', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/comments/commentAvatar.html',
        scope: {
            user: '='
        }
    };
});