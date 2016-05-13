app.directive('loadOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/posts/loadOrderNote.html',
        scope: {
        	note: '=',
            showAuthorColumn: '=?'
        }
    };
});