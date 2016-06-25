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
            modId: '=?'
        }
    };
});

app.controller('installOrderNoteController', function ($scope) {
    // set defaults
    $scope.showUserColumn = angular.defined($scope.showUserColumn) ? $scope.showUserColumn : true;
    $scope.showActions = angular.defined($scope.showActions) ? $scope.showActions : true;
});