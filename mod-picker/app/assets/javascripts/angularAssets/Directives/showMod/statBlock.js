app.directive('statBlock', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/statBlock.html',
        scope: {
            rows: '='
        }
    };
});
