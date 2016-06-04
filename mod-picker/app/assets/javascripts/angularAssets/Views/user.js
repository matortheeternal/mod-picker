app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.user', {
            templateUrl: '/resources/partials/showUser/user.html',
            controller: 'userController',
            url: '/profile/:userId',
            redirectTo: 'base.user.Social',
            resolve: {
                user: function(userService, $stateParams) {
                    return userService.retrieveUser($stateParams.userId);
                }
            }
        }).state('base.user.Social', {
            templateUrl: '/resources/partials/showUser/social.html',
        }).state('base.user.Mod Lists', {
            templateUrl: '/resources/partials/showUser/lists.html',
        }).state('base.user.Mods', {
            templateUrl: '/resources/partials/showUser/mods.html',
        }).state('base.user.Contributions', {
            templateUrl: '/resources/partials/showUser/contributions.html',
        });
}]);

app.controller('userController', function ($scope, user) {
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

    //of the tab data
    $scope.tabs = [
        { name: 'Social'},
        { name: 'Mod Lists'},
        { name: 'Mods'},
        { name: 'Contributions'}
    ];
});
