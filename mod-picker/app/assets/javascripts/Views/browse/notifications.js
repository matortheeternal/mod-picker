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
    $scope.pages = {};

    // set page title
    $scope.$emit('setPageTitle', 'Notifications');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.notifications]);

    // prepare notifications factory
    notificationsFactory.setCurrentUserID($rootScope.currentUser.id);

    // data retrieval
    $scope.retrieveNotifications = function(page) {
        var options = {
            page: page || 1
        };
        notificationService.retrieveNotifications(options, $scope.pages).then(function(data) {
            $scope.notifications = data.notifications;
        }, function(response) {
            $scope.errors.notifications = response;
        });
    };

    // retrieve data when we first visit the page
    $scope.retrieveNotifications();
});