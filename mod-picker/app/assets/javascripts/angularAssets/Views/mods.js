
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, modService, sliderFactory) {
    $scope.filters = {};

    //TODO: everything below should be handled differently
    // -> remove redundancy
    // -> probably don't set visibility in the controller but in the view

    /* visibility of extended filters */
    $scope.nmVisible = false;
    $scope.nmToggle = function () {
        $scope.nmVisible = !$scope.nmVisible;
        if ($scope.nmVisbile) {
            $scope.$broadcast('refreshSlider');
        }
    };

    $scope.mpVisible = false;
    $scope.mpToggle = function () {
        $scope.mpVisible = !$scope.mpVisible;
        if ($scope.mpVisbile) {
            $scope.$broadcast('refreshSlider');
        }
    };

    /* data */
    // TODO: replace firstGet with $scope.mods
    var firstGet = false;
    $scope.getMods = function() {
        delete $scope.mods;
        modService.retrieveMods($scope.filters).then(function (data) {
            $scope.mods = data;
            firstGet = true;
        });
    };

    $scope.getMods();

    // create a watch
    var getModsTimeout;
    $scope.$watch('filters', function(filters) {
        if(filters && firstGet) {
            clearTimeout(getModsTimeout);
            getModsTimeout = setTimeout($scope.getMods, 500);
        }
    }, true);
});

