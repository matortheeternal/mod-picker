app.directive('messages', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/messages.html',
        controller: 'messagesController',
        scope: {
            decayTime: '='
        }
    }
});

//TODO: empty controller is probably unnecessary :P
app.controller('messagesController', function ($scope, $timeout) {
    var decay = $scope.decayTime || 5000;
    $scope.messages = [];

    $scope.$on('message', function(event, message) {
        $scope.messages.push(message);
        $timeout(function() {
            var index = $scope.messages.indexOf(message);
            // TODO: We should set display hidden before splicing the message so the transition works
            $scope.messages.splice(index, 1);
        }, decay);
    });
});
