app.directive('statExpander', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/statExpander.html',
        scope: {
            info: '=',
            expanded: '=',
            label: '@'
        },
        transclude: true
    }
});