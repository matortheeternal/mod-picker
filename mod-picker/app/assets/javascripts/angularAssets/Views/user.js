app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.user', {
            templateUrl: '/resources/partials/showUser/user.html',
            controller: 'userController',
            url: '/user/:userId',
            redirectTo: 'base.user.Social'
        }).state('base.user.Social', {
            templateUrl: '/resources/partials/showUser/social.html',
            controller: 'userSocialTabController'
        }).state('base.user.Mod Lists', {
            templateUrl: '/resources/partials/showUser/lists.html'
        }).state('base.user.Mods', {
            templateUrl: '/resources/partials/showUser/mods.html'
        }).state('base.user.Contributions', {
            templateUrl: '/resources/partials/showUser/contributions.html'
        });
}]);

app.controller('userController', function ($scope, $stateParams, currentUser, userService, errorService) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.permissions = currentUser.permissions;

    // set up local variables
    $scope.errors = [];
    $scope.displayErrors = {};
    $scope.pages = {
        profile_comments: {}
    };
    $scope.retrieving = {};

    // retrieve the user object
    userService.retrieveUser($stateParams.userId).then(function(data) {
        $scope.user = data;
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
    }, function(response) {
        errorService.handleError('user', response);
    });



    //of the tab data
    $scope.tabs = [
        { name: 'Social'},
        { name: 'Mod Lists'},
        { name: 'Mods'},
        { name: 'Contributions'}
    ];
});

app.controller('userSocialTabController', function($scope, $stateParams, userService) {
    $scope.retrieveProfileComments = function(page) {
        // TODO: Make options dynamic
        var options = {
            sort: {
                column: 'submitted',
                direction: 'desc'
            },
            page: page || 1
        };
        userService.retrieveProfileComments($stateParams.userId, options, $scope.pages.profile_comments).then(function(data) {
            $scope.user.profile_comments = data;
        }, function(response) {
            $scope.displayErrors.profile_comments = response;
        });
    };

    // retrieve the profile comments
    if (!$scope.retrieving.profile_comments) {
        $scope.retrieving.profile_comments = true;
        $scope.retrieveProfileComments();
    }
});