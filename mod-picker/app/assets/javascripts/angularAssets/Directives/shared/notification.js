app.directive('notification', function() {
    return {
        restrict: 'E',
        template: '<span ng-bind-html="message"></span>',
        scope: {
            notification: '=?'
        },
        controller: 'notificationController'
    }
});

app.controller('notificationController', function ($scope, $sce, $interpolate, notificationsFactory) {
    angular.inherit($scope, 'notification');
    $scope.event = $scope.notification.event;
    $scope.content = $scope.event.content;

    // get template based on event type
    var template = notificationsFactory.getNotification($scope.event);
    $scope.message = $sce.trustAsHtml($interpolate(template)($scope));
});