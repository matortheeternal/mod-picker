
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/installation_notes', {
            templateUrl: '/resources/partials/installation_notes.html',
            controller: 'inotesController'
        }
    );
}]);

app.controller('inotesController', function ($scope, $q, backend) {
    $scope.loading = true;
    backend.retrieveInstallationNotes().then(function (data) {
        $scope.inotes = data;
        $scope.loading = false;
    });
});