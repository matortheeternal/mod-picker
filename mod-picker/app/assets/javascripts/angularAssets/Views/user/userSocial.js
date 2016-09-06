app.controller('userSocialController', function($scope, $stateParams, userService) {
    $scope.retrieveProfileComments = function(page) {
        var options = {
            sort: {
                column: 'submitted',
                direction: 'desc'
            },
            page: page || 1
        };
        userService.retrieveProfileComments($stateParams.userId, options, $scope.pages.profile_comments).then(function(data) {
            $scope.user.profile_comments = data;
        }, function(response) {
            $scope.errors.comments = response;
        });
    };

    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    // retrieve the profile comments
    $scope.retrieveProfileComments();
});