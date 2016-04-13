/**
 * Created by r79 on 2/11/2016.
 */

app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider
        .when('/', {
            templateUrl: '/resources/partials/home.html',
            controller: 'homeController'
        })
        .otherwise({
            redirectTo: '/'
        });
}]);

app.controller('homeController', function($rootScope) {
    $rootScope.twoColumns = false;
});

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