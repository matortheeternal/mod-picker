app.directive('contributionText', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/contributionText.html',
        controller: 'contributionTextController',
        scope: {
            target: '=',
            modelName: '@'
        }
    };
});

app.controller('contributionTextController', function($scope, $rootScope, contributionService, contributionFactory) {
    $scope.modelObj = contributionFactory.getModel($scope.modelName);
    $scope.permissions = angular.copy($rootScope.permissions);

    $scope.removeModeratorMessage = function() {
        var oldMessage = $scope.target.moderator_message;
        $scope.target.moderator_message = null;

        contributionService.updateContribution($scope.modelObj.route, $scope.target.id, $scope.target).then(function() {
            $scope.$emit("successMessage", "Moderator Note removed successfully.");
        }, function(response) {
            var params = { label: 'Error removing Moderator Note', response: response };
            $scope.$emit('errorMessage', params);

            $scope.target.moderator_message = oldMessage;
        });
    };
});
