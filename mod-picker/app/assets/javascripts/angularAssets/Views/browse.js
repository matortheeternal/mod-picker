
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/browse', {
            templateUrl: '/resources/partials/browse.html',
            controller: 'browseController'
        }
    );
}]);

app.controller('browseController', function ($scope, modService) {
    $scope.loading = true;
    modService.retrieveMods().then(function (data) {
        $scope.mods = data;
        $scope.loading = false;
    });
});