
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, modService, sliderFactory) {
    $scope.loading = true;

    /* data */
    modService.retrieveMods().then(function (data) {
        $scope.mods = data;
        $scope.loading = false;
    });
});