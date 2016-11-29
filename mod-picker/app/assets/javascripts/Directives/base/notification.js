app.directive('notification', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/base/notification.html',
        scope: {
            notification: '=?',
            showCreated: '=?'
        },
        controller: 'notificationController'
    }
});

app.controller('notificationController', function($scope, $sce, $interpolate, notificationsFactory) {
    angular.inherit($scope, 'notification');
    if ($scope.notification.hasOwnProperty('event')) {
        $scope.event = $scope.notification.event;
    } else {
        $scope.event = $scope.notification;
    }
    $scope.content = $scope.event.content;

    // get template based on event type
    var template = notificationsFactory.getNotification($scope.event);
    $scope.message = $sce.trustAsHtml($interpolate(template)($scope));
});