app.controller('modListCommentsController', function($scope, contributionService) {
    $scope.retrieveComments = function(page) {
        // TODO: Make options dynamic
        var options = {
            sort: {
                column: 'submitted',
                direction: 'desc'
            },
            page: page || 1
        };
        contributionService.retrieveComments('mod_lists', $scope.mod_list.id, options, $scope.pages.comments).then(function(data) {
            $scope.mod_list.comments = data;
            $scope.retrieving.comments = false;
        }, function(response) {
            $scope.errors.comments = response;
        });
    };

    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    // retrieve mods if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.comments && !$scope.retrieving.comments) {
        $scope.retrieving.comments = true;
        $scope.retrieveComments();
    }
});