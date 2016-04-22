
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/reviews', {
            templateUrl: '/resources/partials/reviews.html',
            controller: 'reviewsController'
        }
    );
}]);

app.controller('reviewsController', function ($scope, $q, backend, sliderFactory) {
    $scope.loading = true;


    /* data */
    //backend.retrieveReviews().then(function (data) {
    //    $scope.reviews = data;
    //    $scope.loading = false;
    //});
});
