app.directive('authorColumn', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notes/authorColumn.html',
        scope: {
            user: '='
        }
    };
});