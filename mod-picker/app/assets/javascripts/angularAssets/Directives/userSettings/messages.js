app.directive('messages', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/messages.html',
        controller: 'messagesController',
        scope: {
            errorDecay: '=?',
            successDecay: '=?'
        }
    }
});

//TODO: empty controller is probably unnecessary :P
app.controller('messagesController', function ($scope, $timeout) {
    // default decay values
    $scope.errorDecay = $scope.errorDecay || 15000;
    $scope.successDecay = $scope.successDecay || 7500;

    // the messages array
    $scope.messages = [];

    $scope.$on('message', function(event, message) {
        var decay = message.type === 'error' ? $scope.errorDecay : $scope.successDecay;
        $scope.messages.push(message);
        $timeout(function() {
            var index = $scope.messages.indexOf(message);
            // TODO: We should set display hidden before splicing the message so the transition works
            $scope.messages.splice(index, 1);
        }, message.decay || decay);
    });
});
