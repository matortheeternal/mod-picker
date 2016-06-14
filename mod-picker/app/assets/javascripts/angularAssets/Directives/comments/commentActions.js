app.directive('commentActions', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/comments/commentActions.html',
        controller: 'commentActionsController',
        scope: {
            comment: '=',
            index: '=',
            currentUser: '=',
            edit: '='
        }
    };
});

app.controller('commentActionsController', function ($scope, contributionService) {
    // this is the report object
    $scope.report = {};

    $scope.toggleReportModal = function(visible) {
        $scope.showReportModal = visible;
    };

    $scope.setPermissions = function() {
        // permissions helper variables
        var user = $scope.currentUser;
        var rep = user.reputation.overall;
        var isAdmin = user && user.role === 'admin';
        var isModerator = user && user.role === 'moderator';
        var isSubmitter = user && user.id === $scope.comment.submitted_by;
        // set up permissions
        $scope.canReply = user || false;
        $scope.canReport = user || false;
        $scope.canEdit = isAdmin || isModerator || isSubmitter;
        $scope.canHide = isAdmin || isModerator;
    };

    $scope.hide = function(hidden) {
        contributionService.hide('comments', $scope.comment.id, hidden).then(function (data) {
            if (data.status == "ok") {
                $scope.comment.hidden = hidden;
            }
        });
    };

    // watch current user so if we get the user object after rendering actions
    // we can re-render them correctly per the user's permissions
    $scope.$watch('currentUser', $scope.setPermissions, true);
});