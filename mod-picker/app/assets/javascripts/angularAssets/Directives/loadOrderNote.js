app.directive('installOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/installOrderNote.html',
        controller: 'iNoteController',
        scope: {
        	inote: '=',
            showAuthorColumn: '='
        }
    };
});

app.controller('iNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
