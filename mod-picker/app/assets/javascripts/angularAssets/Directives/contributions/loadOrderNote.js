app.directive('loadOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/loadOrderNote.html',
        scope: {
            note: '=',
            index: '=',
            currentUser: '=',
            edit: '=?',
            showActions: '=?',
            showUserColumn: '=?'
        }
    };
});

app.controller('installOrderNoteController', function ($scope) {
    // set defaults
    $scope.showUserColumn = angular.defined($scope.showUserColumn) ? $scope.showUserColumn : true;
    $scope.showActions = angular.defined($scope.showActions) ? $scope.showActions : true;
});