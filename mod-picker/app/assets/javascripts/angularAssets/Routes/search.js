/**
 * Created by r79 on 2/11/2016.
 */

app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/search', {
            templateUrl: '/resources/partials/search.html',
            controller: 'searchController',
            reloadOnSearch: false
        }
    );
}]);

app.controller('searchController', function ($scope, $q, backend, $location) {
    $scope.search = {};

    //TODO: make the search parameter shorter, similar to imgur URLs. -> implement two way hashing
    if ($location.search().s) {
        $scope.search.name = $location.search().s;
        processSearch();
    }

    function processSearch() {
        delete $scope.results;
        delete $scope.errorMessage;
        $location.search('s', $scope.search.name);
        $scope.loading = true;
        backend.search($scope.search).then(function (data) {
            $scope.loading = false;
            if (data.length) {
                $scope.results = data;
            } else {
                $scope.errorMessage = "no mod found!"
            }
        });
    }

    $scope.processSearch = processSearch;
});
