app.directive('loadOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/loadOrderNote.html',
        controller: 'lNoteController',
        scope: {
        	lnote: '=',
            showAuthorColumn: '='
        }
    };
});

app.controller('lNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
