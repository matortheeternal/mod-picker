app.directive('installOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notes/installOrderNote.html',
        scope: {
        	note: '=',
            showAuthorColumn: '=',
            modId: '=?'
        }
    };
});