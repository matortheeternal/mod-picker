app.directive('helpPageComments', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/help/helpPageComments.html',
        controller: 'helpPageCommentsController',
        scope: {
            helpPageId: '='
        }
    };
});

app.controller('helpPageCommentsController', function($scope, $rootScope, contributionService, userService, userTitleService) {
    $rootScope.currentGame = {
        url: "skyrim"
    };
    $scope.errors = {};
    $scope.pages = {
        comments: {}
    };
    $scope.helpPage = {
        id: $scope.helpPageId
    };

    // retrieve current user
    userService.retrieveCurrentUser().then(function(currentUser) {
        $rootScope.currentUser = currentUser;
        $rootScope.permissions = currentUser.permissions;
        $scope.currentUser = currentUser;
        $scope.permissions = currentUser.permissions;
    }, function(response) {
        $scope.$emit('errorMessage', response);
    });

    $scope.retrieveComments = function(page) {
        var options = {
            sort: {
                column: 'submitted',
                direction: 'DESC'
            },
            page: page || 1
        };
        contributionService.retrieveComments('help', $scope.helpPageId, options, $scope.pages.comments).then(function(data) {
            $scope.comments = data;
            $scope.commentsReady = true;
        }, function(response) {
            $scope.errors.comments = response;
        });
    };

    // new comment
    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    // get user titles
    userTitleService.retrieveUserTitles().then(function() {
        // retrieve comments when the directive is loaded and we've retrieved user titles
        $scope.retrieveComments();
    }, function(response) {
        $scope.errors.comments = response;
    });
});