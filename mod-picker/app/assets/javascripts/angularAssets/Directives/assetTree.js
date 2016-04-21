app.directive('assetTree', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/assetTree.html',
        controller: 'assetTreeController',
        scope: {
            data: '='
        }
    };
});

app.controller('assetTreeController', function ($scope) {
//leaving this here in case it is needed when the directive is actually made
});
