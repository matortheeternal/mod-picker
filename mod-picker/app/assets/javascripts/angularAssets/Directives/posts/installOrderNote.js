app.directive('installOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/posts/installOrderNote.html',
        scope: {
        	note: '=',
            index: '=',
            user: '=',
            showAuthorColumn: '=',
            modId: '=?'
        }
    };
});