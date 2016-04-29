app.directive('assetTree', function (RecursionHelper) {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/assetTree.html',
        scope: {
            data: '='
        },
        link: function(scope) {
            scope.expanded = false;
            scope.toggle = function () {
                scope.expanded = !scope.expanded;
            }
        }
    }
});
