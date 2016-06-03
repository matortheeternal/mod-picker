app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.user', {
            templateUrl: '/resources/partials/showUser/user.html',
            controller: 'userController',
            url: '/profile/:userId'
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

        var rep = $scope.user.reputation.overall;
        var numEndorsed = 0; //TODO: retrieve the number of endorsements this user has made
        $scope.userCanAddMod = (rep >= 160) || ($scope.user.role === 'admin');
        $scope.userCanAddTags = (rep >= 20) || ($scope.user.role === 'admin');
        //can the current user endorse another person?
        $scope.userCanEndorse = (rep >= 40 && numEndorsed <= 5) || (rep >= 160 && numEndorsed <= 10) || (rep >= 640 && numEndorsed <= 15);
    });

    //of the tab data
    $scope.tabs = [
        { name: 'Social', url: '/resources/partials/showUser/social.html' },
        { name: 'Mod Lists', url: '/resources/partials/showUser/lists.html' },
        { name: 'Mods', url: '/resources/partials/showUser/mods.html' },
        { name: 'Contributions', url: '/resources/partials/showUser/contributions.html' }
    ];

    $scope.currentTab = $scope.tabs[0];
});
