app.directive('tabViews', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tabViews.html',
        controller: 'tabViewsController'
    };
});

app.controller('tabViewsController', function($scope, $state) {
    $scope.visible = function(tabName) {
        return $state.includes('**.' + tabName);
    };
});
