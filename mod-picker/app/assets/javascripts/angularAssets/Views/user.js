app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/user/:userId', {
            templateUrl: '/resources/partials/user.html',
            controller: 'userController'
        }
    );
}]);

app.controller('userController', function ($scope, $q, $routeParams, userService) {
    userService.retrieveUser($routeParams.userId).then(function (mod) {
        $scope.user = user;
    });

    //of the tab data
    $scope.tabs = [
        { name: 'Compatibility notes', url: '/resources/partials/showMod/compatibility.html' },
        { name: 'Installation', url: '/resources/partials/showMod/installation.html' },
        { name: 'Reviews', url: '/resources/partials/showMod/reviews.html' },
        { name: 'Analysis', url: '/resources/partials/showMod/analysis.html' }
    ];

    $scope.currentTab = $scope.tabs[0];
});
