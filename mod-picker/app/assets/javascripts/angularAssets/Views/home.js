/**
 * Created by r79 on 2/11/2016.
 */

app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.home', {
            templateUrl: '/resources/partials/home.html',
            url: '/'
        });
}]);

app.controller('searchController', function($scope, $location) {
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
