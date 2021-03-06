app.directive('userNotifications', function(formUtils) {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/base/userNotifications.html',
        scope: {
            notifications: '='
        },
        link: formUtils.hideWhenDocumentClicked('showNotifications'),
        controller: 'userNotificationsController'
    }
});

app.controller('userNotificationsController', function($scope, $rootScope, $timeout, notificationService, notificationsFactory) {
    // initialize variables
    var thirtySeconds = 30 * 1000;
    var fiveMinutes = 5 * 60 * 1000;
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
        }, thirtySeconds);
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

    $scope.autoRefresh = function() {
        if (!$scope.waiting) {
            $scope.refreshNotifications();
            // autorefresh notifications every 5 minutes
            $timeout($scope.autoRefresh, fiveMinutes);
        }
    };

    // start autorefresh in 5 minutes
    $timeout($scope.autoRefresh, fiveMinutes);
});