app.directive('compatibilityNote', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/compatibilityNote.html',
        controller: 'compatibilityNoteController',
        scope: {
            note: '=',
            index: '=',
            edit: '=?',
            showMarks: '=?',
            showUserColumn: '=?',
            showResolutionOptions: '=?',
            modDataLoaded: '=?',
            modId: '=?'
        },
        link: function(scope, element) {
            scope.element = element;
        }
    }
});

app.controller('compatibilityNoteController', function($scope, $rootScope) {
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
    $scope.getVerb = function() {
        switch ($scope.note.status) {
            case "incompatible":
                return "with";
            case "partially incompatible":
                return "with";
            default:
                return "for";
        }
    };

    $scope.resolve = function(action, index) {
        if ($scope.note.resolved) {
            return;
        }
        var options = {
            note: $scope.note,
            action: action,
            index: index
        };
        $scope.$emit('resolveCompatibilityNote', options);
    };

    $scope.getTitle = function() {
        // TODO: Titles for when the note is resolved/ignored
        if (!$scope.modDataLoaded) {
            return 'You must visit the mods tab before you can use this action.'
        }
    };

    // set compatibility_verb
    $scope.note.compatibility_verb = $scope.getVerb();
});
