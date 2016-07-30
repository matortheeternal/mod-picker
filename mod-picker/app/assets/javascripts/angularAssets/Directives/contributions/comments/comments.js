app.directive('comments', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/comments/comments.html',
        controller: 'commentsController',
        scope: {
            pageData: '=',
            currentUser: '=',
            objectType: '=',
            object: '=',
        }
    };
});

app.controller('commentsController', function ($scope, commentService) {
    $scope.retrievalCallback = function(page) {
        // TODO: Make options dynamic
        var options = {
            sort: {
                column: 'submitted',
                direction: 'desc'
            },
            page: page || 1
        };
        commentService.retrieveComments($scope.object.id, $scope.objectType.toLowerCase(), options, $scope.pageData).then(function(data) {
            $scope.comments = data;
        }, function(response) {
            var params = { label: 'Error retrieving comments', response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    $scope.retrievalCallback();
});
