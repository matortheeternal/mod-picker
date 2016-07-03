app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.landing', {
        templateUrl: '/resources/partials/landingPage/landing.html',
        controller: 'landingController',
        url: '/landing',
        redirectTo: 'base.landing.Reviews'
    }).state('base.landing.Reviews', {
        templateUrl: '/resources/partials/landingPage/reviews.html',
        url: '/reviews'
    }).state('base.landing.Compatibility Notes', {
        templateUrl: '/resources/partials/landingPage/compatibilityNotes.html',
        url: '/compatibility'
    }).state('base.landing.Install Order Notes', {
        templateUrl: '/resources/partials/landingPage/installOrderNotes.html',
        url: '/install-order'
    }).state('base.landing.Load Order Notes', {
        templateUrl: '/resources/partials/landingPage/loadOrderNotes.html',
        url: '/load-order'
    }).state('base.landing.Corrections', {
        templateUrl: '/resources/partials/landingPage/corrections.html',
        url: '/corrections'
    });
}]);

app.controller('searchController', function($scope, $location) {
    $scope.loading = false;
    $scope.processSearch = function() {
        $scope.loading = true;
        //TODO: remove mockup
        setTimeout(function() {
            $scope.loading = false;
            $scope.$apply();
        }, 1000);
    };
});

app.controller('landingController', function($scope, $q, landingService, userService) {
    $scope.currentUser = currentUser;

    $scope.tabs = [
        { name: 'Reviews' },
        { name: 'Compatibility Notes' },
        { name: 'Install Order Notes' },
        { name: 'Load Order Notes' },
        { name: 'Corrections' }
    ];

    landingService.retrieveLanding().then(function(data) {
        $scope.landingData = data;
    });

    $scope.wordCount = function(string) {
        return string.match(/(\S+)/g).length;
    };

    //returns just the first 50 words of a string
    $scope.reduceText = function(string) {
        words = string.split(' ', 50);
        return words.join(' ');
    };
});
