app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('user', {
            templateUrl: '/resources/partials/showUser/user.html',
            controller: 'userController',
            url: '/user/:userId'
        }
    );
}]);

app.controller('userController', function ($scope, $q, $stateParams, userService) {
    userService.retrieveUser($stateParams.userId).then(function (user) {
        $scope.user = user;
        $scope.roleClass = "user-role-" + $scope.user.role;
        //formatting the role displayed on the site
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
            default:
                //shows nothing if they have no notable role
                $scope.user.role = "";
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
