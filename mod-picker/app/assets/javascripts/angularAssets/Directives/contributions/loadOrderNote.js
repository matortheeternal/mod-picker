app.directive('loadOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/loadOrderNote.html',
        controller: 'loadOrderNoteController',
        scope: {
            note: '=',
            index: '=',
            currentUser: '=',
            edit: '=?',
            showActions: '=?',
            showUserColumn: '=?',
            showResolutionOptions: '=?'
        }
    };
});

app.controller('loadOrderNoteController', function ($scope) {
    // set default values
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
        $scope.$emit('resolveLoadOrderNote', options);
    };
});