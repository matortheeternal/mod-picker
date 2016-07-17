app.directive('sortControl', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/sortControl.html',
        scope: {
            column: '=',
            direction: '=',
            retrieveCallback: '&?',
            sortOptions: '='
        }
    };
});
