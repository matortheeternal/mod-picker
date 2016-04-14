
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, modService, sliderFactory) {
    //TODO: scope.loading is deprecated
    $scope.loading = true;

    //TODO: everything below should be handled differently
    // -> remove redundancy
    // -> probably don't set visibility in the controller but in the view

    /* visibility of extended filters */
    $scope.nm_visible = false;
    $scope.nm_toggle = function () {
        $scope.nm_visible = !$scope.nm_visible;
        if ($scope.nm_visbile) {
            $scope.$broadcast('refreshSlider');
        }
    };

    $scope.mp_visible = false;
    $scope.mp_toggle = function () {
        $scope.mp_visible = !$scope.mp_visible;
        if ($scope.mp_visbile) {
            $scope.$broadcast('refreshSlider');
        }
    };

    /* data */
    modService.retrieveMods().then(function (data) {
        $scope.mods = data;
        //TODO: scope.loading is deprecated
        $scope.loading = false;
    });
});
