app.directive('messages', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/messages.html',
        controller: 'messagesController',
        scope: {
            event: '@',
            errorDecay: '=?',
            successDecay: '=?'
        }
    }
});

//TODO: empty controller is probably unnecessary :P
app.controller('messagesController', function ($scope, $timeout) {
    // default values
    $scope.event = $scope.event || 'message';
    $scope.errorDecay = $scope.errorDecay || 15000;
    $scope.successDecay = $scope.successDecay || 7500;

    // the messages array
    $scope.messages = [];

    $scope.$on($scope.event, function(event, message) {
        var decay = message.type === 'success' ? $scope.successDecay : $scope.errorDecay;
        $scope.messages.push(message);
        $timeout(function() {
            var index = $scope.messages.indexOf(message);
            if (index > -1) $scope.messages.splice(index, 1);
        }, message.decay || decay);
    });
});
