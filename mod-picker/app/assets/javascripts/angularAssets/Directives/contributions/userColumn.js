app.directive('userColumn', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/userColumn.html',
        scope: {
            user: '=',
            editors: '=?',
            index: '='
        }
    };
});