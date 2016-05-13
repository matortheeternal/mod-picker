/**
 * Created by ThreeTen on 4/29/2016.
 */

app.directive('compatibilityNote', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/notePartials/compatibilityNote.html',
        controller: 'compatibilityNoteController',
        scope: {
        	note: '=',
            showAuthorColumn: '='
        }
    }
});

//TODO: empty controller is probably unnecessary :P
app.controller('compatibilityNoteController', function ($scope) {
});
