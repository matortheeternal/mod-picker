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

app.controller('homeController', function($scope, $rootScope, $q, tabsFactory, helpFactory, homeService) {
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // set page title
    $scope.$emit('setPageTitle', 'Home');
    // set up tabs
    $scope.tabs = tabsFactory.buildHomeTabs();

    // set help context
    var helpContexts = helpFactory.homeContext($scope.currentUser);
    helpFactory.setHelpContexts($scope, helpContexts);

    // retrieve data
    homeService.retrieveHome().then(function(data) {
        $scope.recent = data.recent;
        $scope.articles = data.articles;
    });
});
