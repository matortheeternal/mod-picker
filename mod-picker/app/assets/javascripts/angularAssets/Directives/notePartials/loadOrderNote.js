app.directive('loadOrderNote', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/notePartials/loadOrderNote.html',
        controller: 'loadOrderNoteController',
        scope: {
            loadOrderNote: '='
        }
    };
});

app.controller('loadOrderNoteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
