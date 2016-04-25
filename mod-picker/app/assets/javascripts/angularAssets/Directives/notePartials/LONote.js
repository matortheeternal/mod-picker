app.directive('LoNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/LoNote.html',
        controller: 'LoNoteController',
        scope: {
            note: '='
        }
    };
});

app.controller('LoNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
