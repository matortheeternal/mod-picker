app.directive('errorDisplay', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/errorDisplay.html',
        scope: {
            errors: '=',
            label: '@',
            contentClass: '@'
        }
    }
});