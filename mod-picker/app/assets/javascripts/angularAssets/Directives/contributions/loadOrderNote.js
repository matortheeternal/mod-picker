app.directive('loadOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/loadOrderNote.html',
        scope: {
            note: '=',
            index: '=',
            user: '=',
            edit: '=?',
            showUserColumn: '='
        }
    };
});