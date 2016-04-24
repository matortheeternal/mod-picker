app.directive('LONote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/LONote.html',
        controller: 'LONoteController',
        scope: {
            note: '='
        }
    };
});

app.controller('LONoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
