app.directive('statExpander', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/statExpander.html',
        scope: {
            info: '=',
            expanded: '=',
            label: '@'
        },
        transclude: true
    }
});