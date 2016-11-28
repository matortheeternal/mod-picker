app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.activity', {
        templateUrl: '/resources/partials/base/activity.html',
        controller: 'activityController',
        url: '/activity',
        resolve: {
            permissions: function($q, currentUser, errorService) {
                var permissions = $q.defer();
                if (currentUser.permissions.canModerate) {
                    permissions.resolve(currentUser.permissions);
                } else {
                    var errorObj = errorService.frontendError('Error accessing Site Activity.', 'base.activity', 403, 'Not Authorized');
                    permissions.reject(errorObj);
                }
                return permissions.promise;
            }
        }
    });
}]);

app.controller('activityController', function($scope, $rootScope, permissions, notificationService, helpFactory, notificationsFactory) {
    // initialize local variables
    $scope.errors = {};
    $scope.pages = {};

    // set page title
    $scope.$emit('setPageTitle', 'Site Activity');
    $scope.permissions = permissions;
    // set help context
    helpFactory.setHelpContexts($scope, []);

    // prepare notifications factory
    notificationsFactory.setCurrentUserID($rootScope.currentUser.id);

    // data retrieval
    $scope.retrieveEvents = function(page) {
        var options = {
            page: page || 1
        };
        notificationService.retrieveEvents(options, $scope.pages).then(function(data) {
            $scope.events = data.events;
        }, function(response) {
            $scope.errors.events = response;
        });
    };

    // retrieve data when we first visit the page
    $scope.retrieveEvents();
});
