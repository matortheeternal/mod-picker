app.directive('iNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/iNote.html',
        controller: 'iNoteController',
        scope: {
            note: '='
        }
    };
});

app.controller('iNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
