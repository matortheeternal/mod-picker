app.directive('postText', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/posts/postText.html',
        scope: {
            target: '='
        }
    };
});