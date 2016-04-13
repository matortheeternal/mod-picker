/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('note', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/note.html',
        controller: 'noteController',
        scope: {
            note: '='
        }
    };
});

app.controller('noteController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
