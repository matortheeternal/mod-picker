app.directive('installOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/installOrderNote.html',
        controller: 'installOrderNoteController',
        scope: {
            note: '=',
            index: '=',
            currentUser: '=',
            edit: '=?',
            showActions: '=?',
            showUserColumn: '=?',
            showResolutionOptions: '=?',
            modId: '=?'
        }
    };
});

app.controller('installOrderNoteController', function ($scope) {
    // default scope attributes
    angular.default($scope, 'showUserColumn', true);
    angular.default($scope, 'showActions', true);

    $scope.resolve = function(action, index) {
        if ($scope.note.resolved) {
            return;
        }
        var options = {
            note: $scope.note,
            action: action,
            index: index
        };
        $scope.$emit('resolveInstallOrderNote', options);
    };
});