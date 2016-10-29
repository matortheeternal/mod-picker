app.directive('contributionText', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/contributionText.html',
        scope: {
            target: '='
        }
    };
});
