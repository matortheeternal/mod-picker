app.directive('assetTree', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/assetTree.html',
        scope: {
            assets: '='
        },
        link: function(scope) {
            scope.expanded = false;
            scope.toggle = function(asset) {
                asset.expanded = !asset.expanded;
            }
        }
    }
});
