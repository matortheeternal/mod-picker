app.directive('appeal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/appeal.html',
        scope: {
        	appeal: '=',
            index: '=',
            user: '=',
            edit: '=?',
            showAuthorColumn: '='
        }
    }
});