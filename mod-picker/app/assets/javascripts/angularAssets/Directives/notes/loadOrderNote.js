app.directive('loadOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notes/loadOrderNote.html',
        scope: {
        	note: '=',
            showAuthorColumn: '=?'
        }
    };
});