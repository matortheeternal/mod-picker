app.directive('installOrderNote', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/installOrderNote.html',
        controller: 'installOrderNoteController',
        scope: {
            note: '=',
            index: '=',
            edit: '=?',
            showMarks: '=?',
            showUserColumn: '=?',
            showResolutionOptions: '=?',
            modId: '=?'
        },
        link: function(scope, element) {
            scope.element = element;
        }
    };
});

app.controller('installOrderNoteController', function($scope, $rootScope) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;

    // default scope attributes
    angular.default($scope, 'showUserColumn', true);
    angular.default($scope, 'showMarks', true);

    // initialize variables
    $scope.standingClasses = {
        good: 'fa-check-circle',
        unknown: 'fa-question-circle',
        bad: 'fa-exclamation-circle'
    };

    // helper functions
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