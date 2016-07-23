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
    // set defaults
    $scope.showUserColumn = angular.isDefined($scope.showUserColumn) ? $scope.showUserColumn : true;
    $scope.showActions = angular.isDefined($scope.showActions) ? $scope.showActions : true;

    $scope.getResolutionStatus = function() {
        if ($scope.ignored) {
            return "Ignored";
        } else if ($scope.resolved) {
            return "Resolved";
        } else {
            return "Unresolved";
        }
    };

    $scope.resolve = function(action, index) {
        var options = {
            note: $scope.note,
            action: action,
            index: index
        };
        $scope.$emit('resolveInstallOrderNote', options);
    };
});