
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/users', {
            templateUrl: '/resources/partials/users.html',
            controller: 'usersController'
        }
    );
}]);

app.controller('usersController', function ($scope, $q, backend, sliderFactory) {
    ///* data */
    //backend.retrieveUsers().then(function (data) {
    //    $scope.users = data;
    //    $scope.loading = false;
    //});
});
