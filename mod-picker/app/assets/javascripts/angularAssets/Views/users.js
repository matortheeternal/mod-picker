
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/users', {
            templateUrl: '/resources/partials/users.html',
            controller: 'usersController'
        }
    );
}]);

app.controller('usersController', function ($scope, $q, backend) {
    $scope.loading = true;
    backend.retrieveUsers().then(function (data) {
        $scope.users = data;
        $scope.loading = false;
    });
});