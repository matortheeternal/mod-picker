/**
 * Created by ThreeTen on 4/29/2016.
 */

app.directive('compatibilityNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/compatibilityNote.html',
        controller: 'compatibilityNoteController',
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
    }
});

app.controller('compatibilityNoteController', function ($scope) {
    // set defaults
    $scope.showUserColumn = angular.isDefined($scope.showUserColumn) ? $scope.showUserColumn : true;
    $scope.showActions = angular.isDefined($scope.showActions) ? $scope.showActions : true;

    $scope.getVerb = function () {
        switch ($scope.note.status) {
            case "incompatible":
                return "with";
            case "partially incompatible":
                return "with";
            default:
                return "for";
        }
    };

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
        $scope.$emit('resolveCompatibilityNote', options);
    };

    // set compatibility_verb
    $scope.note.compatibility_verb = $scope.getVerb();
});
