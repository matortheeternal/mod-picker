app.directive('comments', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/comments.html',
        controller: 'commentsController',
        scope: {
            comments: '=',
            currentUser: '=',
            modelName: '=',
            target: '='
        }
    };
});

app.controller('commentsController', function ($scope, contributionService) {
    // update the markdown editor
    $scope.updateEditor = function() {
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    // start a new comment
    $scope.newComment = function() {
        $scope.activeComment = {
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
                commentable_id: $scope.target.id,
                commentable_type: $scope.modelName,
                text_body: comment.text_body
            }
        };
        comment.submitting = true;

        // use update or submit contribution
        if (comment.editing) {
            var commentId = comment.original.id;
            contributionService.updateContribution("comments", commentId, commentObj).then(function() {
                $scope.$emit('successMessage', 'Comment updated successfully.');
                // update original comment object and discard copy
                updateCallback();
                discardCallback();
            }, function(response) {
                var params = {label: 'Error updating Comment', response: response};
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("comments", commentObj).then(function() {
                $scope.$emit('successMessage', 'Comment submitted successfully.');
                // TODO: push the comment onto the comments array
                discardCallback();
            }, function(response) {
                var params = {label: 'Error submitting Comment', response: response};
                $scope.$emit('errorMessage', params);
            });
        }
    };

    $scope.$on('startNewComment', function() {
        $scope.newComment();
    });
});