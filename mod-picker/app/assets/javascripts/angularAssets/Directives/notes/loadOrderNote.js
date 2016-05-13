app.directive('loadOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notes/loadOrderNote.html',
        controller: 'loadOrderNoteController',
        scope: {
        	note: '=',
            showAuthorColumn: '=?'
        }
    };
});

app.controller('loadOrderNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
