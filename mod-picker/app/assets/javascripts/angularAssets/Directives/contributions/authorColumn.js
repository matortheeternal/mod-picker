app.directive('authorColumn', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/authorColumn.html',
        scope: {
            user: '=',
            index: '='
        }
    };
});