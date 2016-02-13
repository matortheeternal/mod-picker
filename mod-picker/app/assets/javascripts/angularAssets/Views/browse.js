
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/browse', {
            templateUrl: '/resources/partials/browse.html',
            controller: 'browseController'
        }
    );
}]);

app.controller('browseController', function ($scope, $q, backend) {
    $scope.loading = true;
    backend.retrieveMods().then(function (data) {
        $scope.mods = data;
        $scope.loading = false;
    });
});