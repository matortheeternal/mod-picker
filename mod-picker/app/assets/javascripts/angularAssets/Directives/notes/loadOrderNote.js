app.directive('loadOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notes/loadOrderNote.html',
        controller: 'loadOrderNoteController',
        scope: {
        	note: '=',
            showAuthorColumn: '=?'
        }
    };
});

app.controller('loadOrderNoteController', function ($scope, modService) {
    $scope.helpfulMark = function(helpful) {
        if ($scope.note.helpful == helpful) {
            modService.helpfulMark("load_order_notes", $scope.note.id).then(function (data) {
                if (data.status == "ok") {
                    delete $scope.note.helpful;
                }
            });
        } else {
            modService.helpfulMark("load_order_notes", $scope.note.id, helpful).then(function (data) {
                if (data.status == "ok") {
                    $scope.note.helpful = helpful;
                }
            });
        }
    };
});
