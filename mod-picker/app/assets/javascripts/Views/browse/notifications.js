app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.notifications', {
        url: '/notifications',
        templateUrl: '/resources/partials/browse/notifications.html',
        controller: 'notificationsController'
    })
}]);

app.controller('notificationsController', function($scope, $rootScope, notificationService, helpFactory, notificationsFactory) {
    // initialize local variables
    $scope.errors = {};
    $scope.pages = {
        notifications: {}
    };

    // prepare notifications factory
    notificationsFactory.setCurrentUserID($rootScope.currentUser.id);

    // set help context
    $scope.$emit('setHelpContexts', [helpFactory.notifications]);

    // data retrieval
    $scope.retrieveNotifications = function(page) {
        var options = {
            page: page || 1
        };
        notificationService.retrieveNotifications(options, $scope.pages.notifications).then(function(data) {
            $scope.notifications = data.notifications;
        }, function(response) {
            $scope.errors.notifications = response;
        });
    };

    // retrieve data when we first visit the page
    $scope.retrieveNotifications();
});