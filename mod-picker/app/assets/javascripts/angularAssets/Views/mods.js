
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, backend) {
    $scope.loading = true;
    backend.retrieveMods().then(function (data) {
        $scope.mods = data;
        $scope.loading = false;
    });
});