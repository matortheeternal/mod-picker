app.directive('messages', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/messages.html',
        controller: 'messagesController',
        scope: {
            event: '@',
            errorDecay: '=?',
            successDecay: '=?'
        }
    }
});

app.controller('messagesController', function ($scope, $timeout) {
    // default values
    $scope.event = $scope.event || 'message';
    $scope.errorDecay = $scope.errorDecay || 15000;
    $scope.successDecay = $scope.successDecay || 7500;

    // the messages array
    $scope.messages = [];

    $scope.$on($scope.event, function(event, message) {
        var isSuccessMessage = message.type === 'success';
        var decay = isSuccessMessage ? $scope.successDecay : $scope.errorDecay;
        if (isSuccessMessage) $scope.messages = [];

        // shift messages off the array until we have 3
        while ($scope.messages.length >= 3) $scope.messages.shift();

        // push the new message onto the view
        $scope.$applyAsync(function() {
            $scope.messages.push(message);
        });

        // timeout before removing the message automatically
        $timeout(function() {
            var index = $scope.messages.indexOf(message);
            if (index > -1) $scope.messages.splice(index, 1);
        }, message.decay || decay);
    });
});
