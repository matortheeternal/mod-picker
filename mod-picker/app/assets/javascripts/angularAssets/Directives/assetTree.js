app.directive('assetTree', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/assetTree.html',
        scope: {
            'data': '='
        }
    }
});