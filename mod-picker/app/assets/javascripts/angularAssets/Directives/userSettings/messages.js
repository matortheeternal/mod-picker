/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('messages', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/userSettings/messages.html',
        controller: 'messagesController',
        scope: {
        	successMessage: '@',
        	errors: '=',
            successBool: '='
        }
    }
});

//TODO: empty controller is probably unnecessary :P
app.controller('messagesController', function ($scope, $timeout) {
    $scope.$watch('successBool', function(newValue) {
        if(newValue) {
            $timeout(function() {
                $scope.successBool = false;
            }, 7500);
        }
    });
});
