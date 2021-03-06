app.controller('modListCommentsController', function($scope, $state, contributionService) {
    if ($scope.mod_list.disable_comments) {
        $state.go('base.mod-list.Details', {}, { location: 'replace' });
        return;
    }

    $scope.retrieveComments = function(page) {
        // TODO: Make options dynamic
        var options = {
            sort: {
                column: 'submitted',
                direction: 'DESC'
            },
            page: page || 1
        };
        contributionService.retrieveComments('mod_lists', $scope.mod_list.id, options, $scope.pages.comments).then(function(data) {
            $scope.comments = data;
            $scope.commentsReady = true;
            $scope.resetSticky();
        }, function(response) {
            $scope.errors.comments = response;
        });
    };

    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    // retrieve comments when the state is first loaded
    $scope.retrieveComments();
});