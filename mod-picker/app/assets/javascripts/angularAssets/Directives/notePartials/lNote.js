app.directive('lNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/lNote.html',
        controller: 'lNoteController',
        scope: {
        	note: '=',
            showAuthorColumn: '='
        }
    };
});

app.controller('lNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
