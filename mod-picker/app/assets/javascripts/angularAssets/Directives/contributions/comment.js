app.directive('comment', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/comment.html',
        controller: 'commentController',
        scope: {
            comment: '=',
            currentUser: '=',
            index: '=',
            saveCallback: '=',
            isChild: '=?'
        }
    };
});

app.controller('commentController', function ($scope, $filter, $timeout, contributionService) {
    // this is the report object
    $scope.report = {};

    $scope.getDateString = function() {
        var comment = $scope.comment;
        var str = "submitted " + $filter('date')(comment.submitted, 'medium');
        if (comment.edited) {
            str += ", edited " + $filter('date')(comment.edited, 'medium');
        }
        return str;
    };

    $scope.toggleReportModal = function(visible) {
        $scope.showReportModal = visible;
    };

    $scope.reply = function() {
        $scope.activeComment = {
            parent_id: $scope.comment.id,
            text_body: ""
        };

        $scope.comment.replying = true;

        // update markdown editor and validation
        $scope.validateComment();
        $scope.updateEditor();
    };

    // edit comment
    $scope.edit = function() {
        $scope.comment.editing = true;
        $scope.activeComment = {
            text_body: $scope.comment.text_body.slice(0),
            original: $scope.comment,
            editing: true
        };

        // update validation, update the markdown editor
        $scope.validateComment();
        $scope.updateEditor();
    };

    // save comment
    $scope.saveComment = function() {
        $scope.saveCallback($scope.activeComment, $scope.discardComment, $scope.updateComment);
    };

    // update the markdown editor
    $scope.updateEditor = function() {
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    $scope.validateComment = function() {
        // exit if we don't have a activeCompatibilityNote yet
        if (!$scope.activeComment) {
            return;
        }

        $scope.activeComment.valid = $scope.activeComment.text_body.length > 4;
    };

    // discard the comment object
    $scope.discardComment = function() {
        if ($scope.activeComment.editing) {
            $scope.activeComment.original.editing = false;
            $scope.activeComment = null;
        } else {
            $scope.comment.replying = false;
            delete $scope.activeComment;
        }
    };

    // update the comment locally
    $scope.updateComment = function() {
        var originalComment = $scope.comment;
        var updatedComment = $scope.activeComment;
        // update the values on the original comment
        originalComment.text_body = updatedComment.text_body.slice(0);
        originalComment.edited = new Date();
    };

    $scope.setPermissions = function() {
        // permissions helper variables
        var user = $scope.currentUser;
        var rep = user.reputation.overall;
        var isAdmin = user && user.role === 'admin';
        var isModerator = user && user.role === 'moderator';
        var isSubmitter = user && user.id === $scope.comment.submitted_by;
        // set up permissions
        $scope.canReply = !$scope.isChild && user;
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