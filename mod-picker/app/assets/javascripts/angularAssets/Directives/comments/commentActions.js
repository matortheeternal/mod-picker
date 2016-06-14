app.directive('commentActions', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/comments/commentActions.html',
        controller: 'commentActionsController',
        scope: {
            comment: '=',
            index: '=',
            currentUser: '=',
            edit: '='
        }
    };
});

app.controller('commentActionsController', function ($scope) {
    // Stuff
});