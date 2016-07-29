app.directive('comments', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/comments/comments.html',
        controller: 'commentsController',
        scope: {
            comments: '=',
            pageData: '=',
            retrievalCallback: '=',
            currentUser: '=',
            objectType: '=',
            object: '=',
        }
    };
});

app.controller('commentsController', function ($scope, contributionService) {
    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    $scope.retrievalCallback();
});
