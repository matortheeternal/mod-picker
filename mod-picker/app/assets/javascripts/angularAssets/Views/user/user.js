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
                controller: 'userSocialController'
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

app.controller('userController', function($scope, $rootScope, $stateParams, userObject, userService, errorService) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // set up local variables
    $scope.user = userObject.user;
    $scope.user.endorsed = userObject.endorsed;
    $scope.roleClass = "user-role-" + $scope.user.role;
    $scope.pages = {
        profile_comments: {}
    };
    $scope.retrieving = {};

    $scope.roleTexts = {
        admin: "Administrator",
        moderator: "Moderator",
        author: "Mod Author",
        "": ""
    };

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
