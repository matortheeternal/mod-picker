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
                    scope.$applyAsync(function() {
                        scope.showNotifications = false;
                    })
                }
            });
        },
        controller: 'userNotificationsController'
    }
});

app.controller('userNotificationsController', function($scope, $rootScope, $timeout, notificationService, notificationsFactory) {
    notificationsFactory.setCurrentUserID($rootScope.currentUser.id);

    $scope.toggleNotifications = function() {
        $scope.showNotifications = !$scope.showNotifications;
    };

    $scope.refreshNotifications = function() {
        if ($scope.waiting) return;
        $scope.waiting = true;
        delete $scope.notifications;
        notificationService.retrieveRecent().then(function(data) {
            $scope.notifications = data;
        }, function(response) {
            var params = { label: 'Error refreshing notifications', response: response };
            $scope.$emit('errorMessage', params);
        });
        $timeout(function() {
            $scope.waiting = false;
        }, 30000);
    };

    $scope.markAllRead = function() {
        var ids = $scope.notifications.map(function(notification) {
            return notification.event.id;
        });
        delete $scope.notifications;
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