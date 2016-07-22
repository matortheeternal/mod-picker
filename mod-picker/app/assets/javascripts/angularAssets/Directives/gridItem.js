app.directive('gridItem', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/gridItem.html',
        scope: {
            item: '=',
            editing: '=',
            removeCallback: '='
        }
    }
});