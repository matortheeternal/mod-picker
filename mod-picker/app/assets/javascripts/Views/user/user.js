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
                        stateUrl: window.location.href
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
                templateUrl: '/resources/partials/user/modLists.html',
                controller: 'userModListsController'
            }
        },
        url: '/mod-lists'
    }).state('base.user.Mods', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Mods': {
                templateUrl: '/resources/partials/user/mods.html',
                controller: 'userModsController'
            }
        },
        url: '/mods'
    });
}]);

app.controller('userController', function($scope, $rootScope, $stateParams, userObject, userService, helpFactory, eventHandlerFactory, moderationActionsFactory, tabsFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // set up local variables
    $scope.user = userObject.user;
    $scope.user.endorsed = userObject.endorsed;
    $scope.isCurrentUser = $scope.currentUser && $scope.currentUser.id == $scope.user.id;
    $scope.roleClass = "user-role-" + $scope.user.role.replace("_", "-");
    $scope.pages = {
        profile_comments: {}
    };
    $scope.roleTexts = {
        admin: "Administrator",
        moderator: "Moderator",
        writer: "News Writer",
        author: "Mod Author",
        "beta_tester": "Beta Tester",
        restricted: "Restricted",
        banned: "Banned",
        "": ""
    };
    $scope.tabs = tabsFactory.buildUserTabs();

    // initialize local variables
    $scope.report = {
        reportable_id: $scope.user.id,
        reportable_type: 'User'
    };
    var bio = $scope.user.bio;
    $scope.contactInfoPresent = $scope.user.email || bio.nexus_username || bio.lover_username || bio.workshop_username;

    $scope.modelObj = {
        name: "User",
        label: "User",
        route: "users"
    };

    $scope.target = $scope.user;

    // set page title
    $scope.$emit('setPageTitle', $scope.user.username + "'s Profile");

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope);
    moderationActionsFactory.buildActions($scope);

    // set help context
    var helpContexts = helpFactory.userProfileContext($scope.isCurrentUser);
    helpFactory.setHelpContexts($scope, helpContexts);

    // creates or removes the current user's endorsement of a user
    $scope.endorse = function() {
        userService.endorse($scope.user.id, $scope.user.endorsed).then(function() {
            $scope.user.endorsed = !$scope.user.endorsed;
            var msg = ($scope.user.endorsed ? 'E' : 'Une') + 'ndorsed ' + $scope.user.username + ' successfully.';
            $scope.$emit('successMessage', msg);
            $scope.$emit('updateRepPermissions', $scope.user.endorsed);
        }, function(response) {
            var label = 'Error ' + ($scope.user.endorsed ? 'un' : '') + 'endorsing user';
            var params = {label: label, response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    // report modal state
    $scope.toggleReportModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showReportModal = visible;
    };
});
