app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.home', {
        templateUrl: '/resources/partials/home/home.html',
        controller: 'homeController',
        url: '/home',
        redirectTo: 'base.home.Reviews'
    }).state('base.home.Reviews', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Reviews': {
                templateUrl: '/resources/partials/home/recentReviews.html',
                url: '/recent-reviews'
            }
        }
    }).state('base.home.Compatibility Notes', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Compatibility Notes': {
                templateUrl: '/resources/partials/home/recentCompatibilityNotes.html',
                url: '/recent-compatibility'
            }
        }
    }).state('base.home.Install Order Notes', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Install Order Notes': {
                templateUrl: '/resources/partials/home/recentInstallOrderNotes.html',
                url: '/recent-install-order'
            }
        }
    }).state('base.home.Load Order Notes', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Load Order Notes': {
                templateUrl: '/resources/partials/home/recentLoadOrderNotes.html',
                url: '/recent-load-order'
            }
        }
    }).state('base.home.Corrections', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Corrections': {
                templateUrl: '/resources/partials/home/recentCorrections.html',
                url: '/recent-corrections'
            }
        }
    });
}]);

app.controller('homeController', function($scope, $q, homeService, currentUser) {
    $scope.currentUser = currentUser;
    $scope.permissions = currentUser.permissions;

    $scope.tabs = [
        { name: 'Reviews' },
        { name: 'Compatibility Notes' },
        { name: 'Install Order Notes' },
        { name: 'Load Order Notes' },
        { name: 'Corrections' }
    ];

    homeService.retrieveHome().then(function(data) {
        $scope.recent = data.recent;
        $scope.articles = data.articles;
    });
});
