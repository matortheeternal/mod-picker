
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.reviews', {
            templateUrl: '/resources/partials/reviews.html',
            controller: 'reviewsController',
            url: '/reviews'
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
