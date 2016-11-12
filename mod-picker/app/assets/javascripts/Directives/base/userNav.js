app.directive('userNav', function() {
    return {
        priority: 100,
        restrict: 'E',
        templateUrl: '/resources/directives/base/userNav.html',
        scope: false
    }
});