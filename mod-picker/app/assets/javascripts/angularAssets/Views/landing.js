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
    };
});

app.controller('landingController', function ($scope, $q, landingService) {

    //TODO: put this into the Routing logic
    $scope.tabs = [
        { name: 'Recent Reviews', url: '/resources/partials/landingPage/reviews.html'},
        { name: 'Recent Compatibility Notes', url: '/resources/partials/landingPage/compatibilityNotes.html'},
        { name: 'Recent Comments', url: '/resources/partials/landingPage/comments.html'}
    ];

    $scope.currentTab = $scope.tabs[0];


    landingService.retrieveLanding().then(function(data) {
        $scope.landingData = data;
    });
});
