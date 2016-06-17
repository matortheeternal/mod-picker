
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.users', {
            templateUrl: '/resources/partials/browse/users.html',
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
