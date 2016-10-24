app.directive('loadOrderNote', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/loadOrderNote.html',
        controller: 'loadOrderNoteController',
        scope: {
            note: '=',
            index: '=',
            edit: '=?',
            showMarks: '=?',
            showUserColumn: '=?',
            showResolutionOptions: '=?'
        },
        link: function(scope, element) {
            scope.element = element;
        }
    };
});

app.controller('loadOrderNoteController', function($scope, $rootScope) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;

    // set default values
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
        $scope.$emit('resolveLoadOrderNote', options);
    };
});