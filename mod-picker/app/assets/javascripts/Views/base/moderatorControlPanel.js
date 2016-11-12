app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.moderator-cp', {
        templateUrl: '/resources/partials/base/moderatorControlPanel.html',
        controller: 'moderatorController',
        url: '/moderator-cp',
        resolve: {
            permissions: function($q, $rootScope, errorService) {
                var permissions = $q.defer();
                var currentUser = $rootScope.currentUser;
                if (currentUser.permissions.canModerate) {
                    permissions.resolve(currentUser.permissions);
                } else {
                    var errorObj = errorService.frontendError('Error accessing Moderator Control Panel.', 'base.moderator-cp', 403, 'Not Authorized');
                    permissions.reject(errorObj);
                }
                return permissions.promise;
            }
        }
    });
}]);

app.controller('moderatorController', function($scope, permissions, helpFactory) {
    $scope.$emit('setPageTitle', 'Moderator CP');
    $scope.permissions = permissions;
    helpFactory.setHelpContexts($scope, []);
});
