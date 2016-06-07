/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('messages', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/userSettings/messages.html',
        controller: 'messagesController',
        scope: {
            decayTime: '=',
        	successMessage: '@',
        	errors: '=',
            successBool: '='
        }
    }
});

//TODO: empty controller is probably unnecessary :P
app.controller('messagesController', function ($scope, $timeout) {
    var decay = $scope.decayTime || 5000;

    $scope.$watch('successBool', function(newValue) {
        if(newValue) {
            $timeout(function() {
                $scope.successBool = false;
            }, decay);
        }
    });
});
