app.directive('comments', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/comments.html',
        controller: 'commentsController',
        scope: {
            comments: '=',
            modelName: '=?',
            target: '=?',
            eventPrefix: '=?',
            showContext: "=?"
        }
    };
});

app.controller('commentsController', function($scope, $rootScope, contributionService) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;

    // initialize local variables
    $scope.errorEvent = $scope.eventPrefix ? $scope.eventPrefix + 'ErrorMessage' : 'errorMessage';
    $scope.successEvent = $scope.eventPrefix ? $scope.eventPrefix + 'SuccessMessage' : 'successMessage';

    // update the markdown editor
    $scope.updateEditor = function() {
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    // start a new comment
    $scope.newComment = function() {
        // throw exception if we don't have modelName and target defined
        if (!$scope.modelName || !$scope.target) {
            throw "Cannot create a new comment - no target!";
        }

        // prepare activeComment object
        $scope.activeComment = {
            commentable_id: $scope.target.id,
            commentable_type: $scope.modelName,
            text_body: ""
        };

        // update markdown editor and validation
        $scope.validateComment();
        $scope.updateEditor();
    };

    $scope.validateComment = function() {
        // exit if we don't have an activeComment yet
        if (!$scope.activeComment) {
            return;
        }

        $scope.activeComment.valid = $scope.activeComment.text_body.length > 4;
    };

    // discard the new comment object
    $scope.discardNewComment = function() {
        delete $scope.activeComment;
    };

    // save a new comment
    $scope.saveNewComment = function() {
        $scope.saveComment($scope.activeComment, $scope.discardNewComment);
    };

    // push a comment to the local page view
    $scope.pushCommentToView = function(comment) {
        if (comment.parent_id) {
            var parent = $scope.comments.find(function(parent_comment) {
                return parent_comment.id == comment.parent_id;
            });
            if (parent) {
                if (!parent.children) {
                    parent.children = [];
                }
                parent.children.push(comment);
            }
        } else {
            $scope.comments.unshift(comment);
        }
    };

    // save a comment
    $scope.saveComment = function(comment, discardCallback, updateCallback) {
        // return if the comment is invalid
        if (!comment.valid) {
            return;
        }

        // submit the comment
        var commentObj = {
            comment: {
                parent_id: comment.parent_id,
                commentable_id: comment.commentable_id,
                commentable_type: comment.commentable_type,
                text_body: comment.text_body
            }
        };
        comment.submitting = true;

        // use update or submit contribution
        if (comment.editing) {
            var commentId = comment.original.id;
            contributionService.updateContribution("comments", commentId, commentObj).then(function() {
                $scope.$emit($scope.successEvent, 'Comment updated successfully.');
                // update original comment object and discard copy
                updateCallback();
                discardCallback();
            }, function(response) {
                var params = {label: 'Error updating Comment', response: response};
                $scope.$emit($scope.errorEvent, params);
            });
        } else {
            contributionService.submitContribution("comments", commentObj).then(function(comment) {
                $scope.$emit($scope.successEvent, 'Comment submitted successfully.');
                $scope.pushCommentToView(comment);
                discardCallback();
            }, function(response) {
                var params = {label: 'Error submitting Comment', response: response};
                $scope.$emit($scope.errorEvent, params);
            });
        }
    };

    $scope.$on('startNewComment', function() {
        $scope.$broadcast('cancelComment', 0);
        $scope.newComment();
    });

    $scope.$on('cancelComment', function(e, exceptId) {
        if (exceptId == 0) return;
        if ($scope.activeComment) $scope.discardNewComment();
    });
});