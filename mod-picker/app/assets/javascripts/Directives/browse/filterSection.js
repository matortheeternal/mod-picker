app.directive('filterSection', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/filterSection.html',
        scope: {
            name: '@'
        },
        transclude: true,
        link: function(scope, element, attributes) {
            scope.expanded = attributes.expanded == 'true';
        }
    }
});