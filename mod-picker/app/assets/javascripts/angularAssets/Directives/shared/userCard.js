app.directive('userCard', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/userCard.html',
        scope: {
            user: '='
        },
        controller: 'userCardController'
    }
});