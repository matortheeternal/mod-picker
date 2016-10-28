app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.notifications', {
        url: '/notifications',
        templateUrl: '/resources/partials/browse/notifications.html',
        controller: 'notificationsController'
    })
}]);

app.controller('notificationsController', function($scope, $rootScope, notificationService, notificationsFactory) {
    notificationsFactory.setCurrentUserID($rootScope.currentUser.id);
    $scope.errors = {};
    $scope.pages = {
        notifications: {}
    };

    // set page title
    $scope.$emit('setPageTitle', 'Notifications');

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