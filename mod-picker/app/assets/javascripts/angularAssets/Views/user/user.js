app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.user', {
        templateUrl: '/resources/partials/user/user.html',
        controller: 'userController',
        url: '/user/:userId',
        redirectTo: 'base.user.Social',
        resolve: {
            userObject: function(userService, $stateParams, $q) {
                var user = $q.defer();
                userService.retrieveUser($stateParams.userId).then(function(data) {
                    user.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error retrieving user.',
                        response: response,
                        stateName: "base.user",
                        stateUrl: window.location.hash
                    };
                    user.reject(errorObj);
                });
                return user.promise;
            }
        }
    }).state('base.user.Social', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Social': {
                templateUrl: '/resources/partials/user/social.html',
                controller: 'userSocialTabController'
            }
        },
        url: '/social'
    }).state('base.user.Mod Lists', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Mod Lists': {
                templateUrl: '/resources/partials/user/lists.html',
            }
        },
        url: '/mod-lists'
    }).state('base.user.Mods', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Mods': {
                templateUrl: '/resources/partials/user/mods.html'
            }
        },
        url: '/mods'
    });
}]);

app.controller('userController', function($scope, $stateParams, currentUser, userObject) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.permissions = currentUser.permissions;

    // set up local variables
    $scope.user = userObject.user;
    $scope.user.endorsed = userObject.endorsed;
    $scope.pages = {
        profile_comments: {}
    };
    $scope.retrieving = {};

    $scope.roleClass = "user-role-" + $scope.user.role;

    //formatting the role displayed on the site
    switch ($scope.user.role) {
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
        { name: 'Mods'}
    ];

    $scope.endorse = function() {
        userService.endorse($scope.user.id, $scope.user.endorsed).then(function() {
            $scope.user.endorsed = !$scope.user.endorsed;

            //update the currentUser's permissions without having to re-retrieve
            $scope.$emit('updateRepPermissions', $scope.user.endorsed);
        }, function(response) {
            var params = {label: 'Error giving reputation', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response);
        errors.forEach(function(error) {
            $scope.$broadcast('message', error);
        });
        // stop event propagation - we handled it
        event.stopPropagation();
    });
});

app.controller('userSocialTabController', function($scope, $stateParams, userService, contributionService) {
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
            var params = {label: 'Error retrieving Comments', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    // retrieve the profile comments
    if (!$scope.retrieving.profile_comments) {
        $scope.retrieving.profile_comments = true;
        $scope.retrieveProfileComments();
    }
});
