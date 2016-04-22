app.directive('compatibilityNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/compatibilityNote.html',
        controller: 'compatibilityNoteController',
        scope: {
            compatibilityNote: '='
        }
    };
});

app.controller('compatibilityNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
