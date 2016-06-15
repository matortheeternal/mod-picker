app.directive('correction', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/correction.html',
        scope: {
            correction: '=',
            index: '=',
            currentUser: '=',
            edit: '=?',
            showUserColumn: '='
        }
    }
});