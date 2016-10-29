app.directive('contributionText', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/contributionText.html',
        scope: {
            target: '='
        }
    };
});

app.controller('contributionTextController', function($scope, $rootScope, contributionService, contributionFactory) {
    $scope.modelObj = contributionFactory.getModel($scope.modelName);
    $scope.permissions = angular.copy($rootScope.permissions);

    $scope.removeModeratorMessage = function() {
        var oldMessage = $scope.target.moderator_message;

        contributionService.removeModeratorNote($scope.modelObj.route, $scope.target.id).then(function() {
            $scope.$emit("successMessage", "Moderator Note removed successfully.");

            //update ui if the note is successfully removed on the server
            $scope.target.moderator_message = null;
        }, function(response) {
            var params = { label: 'Error removing Moderator Note', response: response };
            $scope.$emit('errorMessage', params);

            $scope.target.moderator_message = oldMessage;
        });
    };
});
