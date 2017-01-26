app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.moderator-cp', {
        templateUrl: '/resources/partials/base/moderatorControlPanel.html',
        controller: 'moderatorController',
        url: '/moderator-cp',
        resolve: {
            stats: function($q, moderationService) {
                var stats = $q.defer();
                moderationService.retrieveStats().then(function(data) {
                    stats.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error accessing moderation control panel.',
                        response: response,
                        stateName: "base.moderator-cp",
                        stateUrl: window.location.hash
                    };
                    stats.reject(errorObj);
                });
                return stats.promise;
            }
        }
    });
}]);

app.controller('moderatorController', function($scope, $rootScope, stats, helpFactory) {
    // get parent variables
    $scope.stats = stats;

    // inherited variables
    $scope.permissions = angular.copy($rootScope.permissions);

    // set page title
    $scope.$emit('setPageTitle', 'Moderator CP');

    // set help context
    helpFactory.setHelpContexts($scope, []);
});
