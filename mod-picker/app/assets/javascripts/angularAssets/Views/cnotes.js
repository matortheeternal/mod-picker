
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/compatibility_notes', {
            templateUrl: '/resources/partials/compatibility_notes.html',
            controller: 'cnotesController'
        }
    );
}]);

app.controller('cnotesController', function ($scope, $q, backend) {
    $scope.loading = true;
    backend.retrieveCompatibilityNotes().then(function (data) {
        $scope.cnotes = data;
        $scope.loading = false;
    });
});