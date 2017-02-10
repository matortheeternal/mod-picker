app.directive('relatedModNote', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/relatedModNote.html',
        controller: 'relatedModNoteController',
        scope: {
            note: '=',
            index: '=',
            edit: '=?',
            showMarks: '=?',
            showUserColumn: '=?',
            modId: '=?'
        }
    }
});

app.controller('relatedModNoteController', function($scope, $rootScope) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;

    // default scope attributes
    angular.default($scope, 'showUserColumn', true);
    angular.default($scope, 'showMarks', true);
});
