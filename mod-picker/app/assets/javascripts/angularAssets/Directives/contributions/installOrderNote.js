app.directive('installOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/installOrderNote.html',
        scope: {
        	note: '=',
            index: '=',
            user: '=',
            edit: '=?',
            showAuthorColumn: '=',
            modId: '=?'
        }
    };
});