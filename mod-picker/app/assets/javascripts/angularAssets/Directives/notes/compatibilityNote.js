/**
 * Created by ThreeTen on 4/29/2016.
 */

app.directive('compatibilityNote', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/notes/compatibilityNote.html',
        controller: 'compatibilityNoteController',
        scope: {
        	note: '=',
            showAuthorColumn: '='
        }
    }
});

app.controller('compatibilityNoteController', function ($scope, modService) {
    // TODO: Should probably be moved into some kind of service
    function getVerb() {
        switch ($scope.note.compatibility_type) {
            case "incompatible":
                return "with";
            case "partially compatible":
                return "with";
            default:
                return "for";
        }
    }

    // set compatibility_verb
    $scope.note.compatibility_verb = getVerb();

    $scope.helpfulMark = function(helpful) {
        if ($scope.note.helpful == helpful) {
            modService.helpfulMark("compatibility_notes", $scope.note.id).then(function (data) {
                if (data.status == "ok") {
                    delete $scope.note.helpful;
                }
            });
        } else {
            modService.helpfulMark("compatibility_notes", $scope.note.id, helpful).then(function (data) {
                if (data.status == "ok") {
                    $scope.note.helpful = helpful;
                }
            });
        }
    };
});
