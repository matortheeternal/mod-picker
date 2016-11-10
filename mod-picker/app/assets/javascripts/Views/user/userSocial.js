app.controller('userSocialController', function($scope, $stateParams, contributionService) {
    $scope.retrieveProfileComments = function(page) {
        var options = {
            sort: {
                column: 'submitted',
                direction: 'DESC'
            },
            page: page || 1
        };
        contributionService.retrieveComments('users', $scope.user.id, options, $scope.pages.profile_comments).then(function(data) {
            $scope.user.profile_comments = data;
        }, function(response) {
            $scope.errors.comments = response;
        });
    };

    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    // retrieve the profile comments
    if (!$scope.user['comments_disabled?']) {
        $scope.retrieveProfileComments();
    }
});