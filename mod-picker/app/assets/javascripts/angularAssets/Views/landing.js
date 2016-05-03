app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('landing', {
            templateUrl: '/resources/partials/landing.html',
            controller: 'landingController',
            url: '/'
        }
    );
}]);

app.controller('landingController', function ($scope, $q, modService) {

});
