app.directive('installOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notes/installOrderNote.html',
        controller: 'installOrderNoteController',
        scope: {
        	note: '=',
            showAuthorColumn: '=',
            modId: '=?'
        }
    };
});

app.controller('installOrderNoteController', function ($scope, modService) {
    $scope.helpfulMark = function(helpful) {
        if ($scope.note.helpful == helpful) {
            modService.helpfulMark("install_order_notes", $scope.note.id).then(function (data) {
                if (data.status == "ok") {
                    delete $scope.note.helpful;
                }
            });
        } else {
            modService.helpfulMark("install_order_notes", $scope.note.id, helpful).then(function (data) {
                if (data.status == "ok") {
                    $scope.note.helpful = helpful;
                }
            });
        }
    };
});
