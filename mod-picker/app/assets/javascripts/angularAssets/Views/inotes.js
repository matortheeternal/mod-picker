
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.installation_notes', {
            templateUrl: '/resources/partials/browse/installation_notes.html',
            controller: 'inotesController',
            url: '/installation_notes'
        }
    );
}]);

app.controller('inotesController', function ($scope, $q, backend, sliderFactory) {
    //TODO: implement dataListLoader
});
