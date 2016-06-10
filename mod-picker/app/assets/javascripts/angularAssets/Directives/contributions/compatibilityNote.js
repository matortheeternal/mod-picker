/**
 * Created by ThreeTen on 4/29/2016.
 */

app.directive('compatibilityNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/compatibilityNote.html',
        controller: 'compatibilityNoteController',
        scope: {
        	note: '=',
            index: '=',
            user: '=',
            edit: '=?',
            showAuthorColumn: '=',
            modId: '=?'
        }
    }
});

app.controller('compatibilityNoteController', function ($scope) {
    // TODO: Should probably be moved into some kind of service
    function getVerb() {
        switch ($scope.note.status) {
            case "incompatible":
                return "with";
            case "partially incompatible":
                return "with";
            default:
                return "for";
        }
    }

    // set compatibility_verb
    $scope.note.compatibility_verb = getVerb();
});
