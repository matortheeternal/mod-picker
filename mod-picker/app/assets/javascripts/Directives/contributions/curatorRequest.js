app.directive('curatorRequest', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/curatorRequest.html',
        controller: 'curatorRequestController',
        scope: {
            curatorRequest: '=data'
        }
    };
});

app.controller('curatorRequestController', function($scope) {

});
