app.directive('curatorRequest', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/curatorRequest.html',
        scope: {
            curatorRequest: '=data',
            index: "="
        }
    };
});