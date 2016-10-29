app.directive('secondaryNav', function() {
    return {
        priority: 100,
        restrict: 'E',
        templateUrl: '/resources/directives/base/secondaryNav.html',
        scope: false,
        controller: 'secondaryNavController'
    }
});

app.controller('secondaryNavController', function($scope, $state) {
    $scope.loading = false;
    $scope.processSearch = function() {
        $state.go("base.mods", {q: $scope.search}, {notify: true});
    };
});