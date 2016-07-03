app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.home', {
        templateUrl: '/resources/partials/home/home.html',
        controller: 'homeController',
        url: '/home',
        redirectTo: 'base.home.Reviews'
    }).state('base.home.Reviews', {
        templateUrl: '/resources/partials/home/reviews.html',
        url: '/recent-reviews'
    }).state('base.home.Compatibility Notes', {
        templateUrl: '/resources/partials/home/compatibilityNotes.html',
        url: '/recent-compatibility'
    }).state('base.home.Install Order Notes', {
        templateUrl: '/resources/partials/home/installOrderNotes.html',
        url: '/recent-install-order'
    }).state('base.home.Load Order Notes', {
        templateUrl: '/resources/partials/home/loadOrderNotes.html',
        url: '/recent-load-order'
    }).state('base.home.Corrections', {
        templateUrl: '/resources/partials/home/corrections.html',
        url: '/recent-corrections'
    });
}]);

app.controller('homeController', function($scope, $q, homeService, currentUser) {
    $scope.currentUser = currentUser;

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

    $scope.wordCount = function(string) {
        return string.match(/(\S+)/g).length;
    };

    //returns just the first 50 words of a string
    $scope.reduceText = function(string) {
        words = string.split(' ', 50);
        return words.join(' ');
    };
});
