app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/user/:userId', {
            templateUrl: '/resources/partials/showUser/user.html',
            controller: 'userController'
        }
    );
}]);

app.controller('userController', function ($scope, $q, $routeParams, userService) {
    userService.retrieveUser($routeParams.userId).then(function (user) {
        $scope.user = user;
        $scope.roleClass = "user-role-" + $scope.user.role;
        switch($scope.user.role) {
            case "admin":
                $scope.user.role = "Administrator";
                break;
            case "moderator":
                $scope.user.role = "Moderator";
                break;
            case "author":
                $scope.user.role = "Mod Author";
                break;
            case "user":
                $scope.user.role = "User";
                break;
        }
    });

    //of the tab data
    $scope.tabs = [
        { name: 'Social', url: '/resources/partials/showUser/social.html' },
        { name: 'Mod Lists and Collections', url: '/resources/partials/showUser/lists.html' },
        { name: 'Authored Mods', url: '/resources/partials/showUser/mods.html' },
        { name: 'Contributions', url: '/resources/partials/showUser/contributions.html' }
    ];

    $scope.currentTab = $scope.tabs[0];
});
