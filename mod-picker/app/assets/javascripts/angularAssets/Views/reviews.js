
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/reviews', {
            templateUrl: '/resources/partials/reviews.html',
            controller: 'reviewsController'
        }
    );
}]);

app.controller('reviewsController', function ($rootScope, $scope, $q, backend, sliderFactory) {
    $rootScope.twoColumns = true;
    $scope.loading = true;


    /* data */
    //backend.retrieveReviews().then(function (data) {
    //    $scope.reviews = data;
    //    $scope.loading = false;
    //});
});