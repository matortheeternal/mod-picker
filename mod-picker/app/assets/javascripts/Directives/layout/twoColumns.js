app.directive('twoColumns', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/layout/twoColumns.html',
        transclude: true
    };
});
