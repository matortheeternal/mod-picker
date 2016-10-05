app.directive('comment', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/comment.html',
        controller: 'commentController',
        scope: {
            comment: '=',
            index: '=',
            saveCallback: '=',
            isChild: '=?',
            eventPrefix: '=?',
            showContext: '=?'
        }
    };
});

app.controller('commentController', function($scope, $rootScope, $filter, $timeout, contributionService) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.currentGame = $rootScope.currentGame;

    // this is the report object
    $scope.report = {
        reportable_id: $scope.comment.id,
        reportable_type: 'Comment'
    };

    $scope.modelObj = {
        name: "Comment",
        label: "Comment",
        route: "comments"
    };

    $scope.target = $scope.comment;
    // initialize local variables
    $scope.errorEvent = $scope.eventPrefix ? $scope.eventPrefix + 'ErrorMessage' : 'errorMessage';

    $scope.getDateString = function() {
        var comment = $scope.comment;
        var str = "submitted " + $filter('date')(comment.submitted, 'medium');
        if (comment.edited) {
            str += ", edited " + $filter('date')(comment.edited, 'medium');
        }
        return str;
    };

    $scope.toggleReportModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showReportModal = visible;
    };

    $scope.getSubmitterAvatar = function() {
        var submitter = $scope.comment.submitter;
        return submitter.avatar || ('/users/' + submitter.title + '.png');
    };

    $scope.reply = function() {
        $scope.activeComment = {
            parent_id: $scope.comment.id,
            commentable_id: $scope.comment.commentable_id,
            commentable_type: $scope.comment.commentable_type.slice(0),
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
            parent_id: $scope.comment.parent_id,
            commentable_id: $scope.comment.commentable_id,
            commentable_type: $scope.comment.commentable_type.slice(0),
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
        if (!user) return;
        var isAdmin = user && user.role === 'admin';
        var isModerator = user && user.role === 'moderator';
        var isSubmitter = user && user.id === $scope.comment.submitted_by;
        // set up permissions
        $scope.isSubmitter = isSubmitter;
        $scope.canReply = !$scope.isChild && user;
        $scope.canReport = user || false;
        $scope.canEdit = isAdmin || isModerator || isSubmitter;
        $scope.canHide = isAdmin || isModerator;
    };

    $scope.hide = function(hidden) {
        contributionService.hide('comments', $scope.comment.id, hidden).then(function(data) {
            $scope.comment.hidden = hidden;
        }, function(response) {
            var approveStr = hidden ? 'hiding' : 'unhiding';
            var params = {
                label: 'Error ' + approveStr + ' comment',
                response: response
            };
            $scope.$emit($scope.errorEvent, params);
        });
    };

    // watch current user so if we get the user object after rendering actions
    // we can re-render them correctly per the user's permissions
    $scope.$watch('currentUser', $scope.setPermissions, true);
});
