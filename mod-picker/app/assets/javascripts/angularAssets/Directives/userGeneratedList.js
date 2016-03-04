app.directive('userGeneratedList', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userGeneratedList.html',
        scope: {
            data: '='
        }
    }
});