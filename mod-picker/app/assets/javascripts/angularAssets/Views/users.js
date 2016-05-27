
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('users', {
            templateUrl: '/resources/partials/users.html',
            controller: 'usersController',
            url: '/users'
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
