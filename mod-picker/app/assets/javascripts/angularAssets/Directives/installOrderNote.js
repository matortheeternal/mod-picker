app.directive('installOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/installOrderNote.html',
        controller: 'installOrderNoteController',
        scope: {
        	inote: '=',
            showAuthorColumn: '='
        }
    };
});

app.controller('installOrderNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
