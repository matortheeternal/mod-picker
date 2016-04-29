app.directive('cNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/cNote.html',
        controller: 'cNoteController',
        scope: {
            note: '='
        }
    };
});

app.controller('cNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
