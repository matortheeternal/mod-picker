app.directive('postText', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notes/postText.html',
        scope: {
            target: '='
        }
    };
});