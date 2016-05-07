app.directive('authorColumn', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/authorColumn.html',
        scope: {
            user: '='
        }
    };
});