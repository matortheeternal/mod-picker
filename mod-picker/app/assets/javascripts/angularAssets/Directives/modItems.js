app.directive('modItems', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modItems.html',
        controller: 'modItemsController',
        scope: {
            mods: '=',
            editing: '=',
            removeCallback: '=',
            tools: '=?'
        }
    }
});

app.controller('modItemsController', function($scope) {
});