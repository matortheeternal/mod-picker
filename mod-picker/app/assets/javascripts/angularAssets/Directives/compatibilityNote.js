/**
 * Created by ThreeTen on 4/29/2016.
 */

app.directive('compatibilityNote', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/compatibilityNote.html',
        controller: 'cNoteController',
        scope: {
        	cnote: '=',
            showAuthorColumn: '='
        }
    }
});

//TODO: empty controller is probably unnecessary :P
app.controller('cNoteController', function ($scope) {
});
