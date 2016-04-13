
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/installation_notes', {
            templateUrl: '/resources/partials/installation_notes.html',
            controller: 'inotesController'
        }
    );
}]);

app.controller('inotesController', function ($rootScope, $scope, $q, backend, sliderFactory) {
    //TODO: implement dataListLoader
    $rootScope.twoColumns = true;
});