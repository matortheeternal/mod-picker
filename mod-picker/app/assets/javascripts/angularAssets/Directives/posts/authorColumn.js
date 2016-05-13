app.directive('authorColumn', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/posts/authorColumn.html',
        scope: {
            user: '=',
            index: '='
        }
    };
});