app.directive('adultMarker', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/adultMarker.html',
        scope: {
            target: '='
        }
    }
});