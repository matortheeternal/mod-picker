app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('landing', {
            templateUrl: '/resources/partials/landing.html',
            controller: 'landingController',
            url: '/'
        }
    );
}]);

app.controller('searchInputController', function ($scope, $location) {
    $scope.loading = false;
    $scope.processSearch = function () {
        $scope.loading = true;
        //TODO: remove mockup
        setTimeout(function () {
            $scope.loading = false;
            $scope.$apply();
        }, 1000);
    }
});

app.controller('landingController', function ($scope, $q, modService) {

});
