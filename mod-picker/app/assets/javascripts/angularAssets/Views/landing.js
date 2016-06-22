app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('landing', {
        templateUrl: '/resources/partials/landing.html',
        controller: 'landingController',
        url: '/'
    });
}]);

app.controller('searchInputController', function($scope, $location) {
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

app.controller('landingController', function($scope, $q, landingService, reviewSectionService, userTitleService) {
    // initialize local variables
    $scope.userTitles = [];

    //TODO: put this into the Routing logic
    $scope.tabs = [
        { name: 'Reviews', url: '/resources/partials/landingPage/reviews.html' },
        { name: 'Compatibility Notes', url: '/resources/partials/landingPage/compatibilityNotes.html' },
        { name: 'Install Order Notes', url: '/resources/partials/landingPage/installOrderNotes.html' },
        { name: 'Load Order Notes', url: '/resources/partials/landingPage/loadOrderNotes.html' },
        { name: 'Corrections', url: '/resources/partials/landingPage/corrections.html' }
    ];

    $scope.currentTab = $scope.tabs[0];

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
