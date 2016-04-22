app.directive('installationNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/installationNote.html',
        controller: 'installationNoteController',
        scope: {
            installationNote: '='
        }
    };
});

app.controller('installationNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
