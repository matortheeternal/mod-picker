/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('textArea', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/textArea.html',
        controller: 'textAreaController',
        scope: {
            data: '='
        }
    }
});

app.controller('textAreaController', function ($scope) {
});
