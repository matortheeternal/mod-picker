app.directive('userNotifications', function($document) {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/userNotifications.html',
        scope: {
            notifications: '='
        },
        link: function(scope, element) {
            $document.on('click', function(e) {
                if (element !== e.target && !element[0].contains(e.target)) {
                    scope.$apply(function() {
                        scope.showNotifications = false;
                    })
                }
            });
        },
        controller: 'userNotificationsController'
    }
});

app.controller('userNotificationsController', function($scope, $rootScope, notificationService, notificationsFactory) {
    notificationsFactory.setCurrentUserID($rootScope.currentUser.id);

    $scope.toggleNotifications = function() {
        $scope.showNotifications = !$scope.showNotifications;
    };

    $scope.refreshNotifications = function() {
        delete $scope.notifications;
        notificationService.retrieveRecent().then(function(data) {
            $scope.notifications = data;
        }, function(response) {
            var params = { label: 'Error refreshing notifications', response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.markAllRead = function() {
        var ids = $scope.notifications.map(function(notification) {
            return notification.event.id;
        });
        notificationService.markRead(ids).then(function(data) {
            $scope.notifications = data;
        }, function(response) {
            var params = { label: 'Error marking notifications as read', response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.$on('$stateChangeStart', function() {
        $scope.showNotifications = false;
    });
});