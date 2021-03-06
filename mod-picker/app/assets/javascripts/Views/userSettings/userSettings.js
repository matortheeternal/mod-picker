app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.settings', {
        templateUrl: '/resources/partials/userSettings/userSettings.html',
        controller: 'userSettingsController',
        url: '/settings',
        redirectTo: 'base.settings.Profile',
        resolve: {
            userObject: function(userSettingsService, currentUser) {
                return userSettingsService.retrieveSettings(currentUser.id);
            }
        }
    }).state('base.settings.Profile', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Profile': {
                templateUrl: '/resources/partials/userSettings/profile.html',
                controller: 'userSettingsProfileController'
            }
        },
        resolve: {
            titleQuote: function(quoteService, currentUser, $q) {
                var output = $q.defer();
                var label = currentUser.permissions.canChangeTitle ? "High Reputation" : "Low Reputation";
                quoteService.getRandomQuote(label).then(function(quote) {
                    quote.text = quote.text.replace(/Talos/g, currentUser.username.capitalize());
                    output.resolve(quote);
                });
                return output.promise;
            }
        },
        url: '/profile'
    }).state('base.settings.Account', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Account': {
                templateUrl: '/resources/partials/userSettings/account.html'
            }
        },
        url: '/account'
    }).state('base.settings.Mod Lists', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Mod Lists': {
                templateUrl: '/resources/partials/userSettings/modLists.html',
                controller: 'userSettingsModListsController'
            }
        },
        url: '/mod-lists'
    }).state('base.settings.Authored Mods', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Authored Mods': {
                templateUrl: '/resources/partials/userSettings/authoredMods.html',
                controller: 'userSettingsModsController'
            }
        },
        url: '/mods'
    }).state('base.settings.API Access', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'API Access': {
                templateUrl: '/resources/partials/userSettings/apiAccess.html',
                controller: 'userSettingsApiController'
            }
        },
        url: '/api-access'
    });
}]);

app.controller('userSettingsController', function($scope, $rootScope, $q, userObject, userSettingsService, themesService, helpFactory, eventHandlerFactory, tabsFactory, objectUtils) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.activeModList = $rootScope.activeModList;
    $scope.permissions = angular.copy($rootScope.permissions);

    // initialize variables
    $scope.user = userObject.user;
    $scope.originalUser = angular.copy($scope.user);
    $scope.settings = $scope.user.settings;
    $scope.errors = {};
    $scope.tabs = tabsFactory.buildUserSettingsTabs();
    $scope.defaultSrc = $scope.user.avatars.medium;
    $scope.avatar = {
        sizes: [
            { label: "medium", src: $scope.defaultSrc }
        ]
    };

    // set page title
    $scope.$emit('setPageTitle', 'Settings');

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope, true);

    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.userSettings]);

    // resets password inputs
    $scope.resetPasswordInputs = function() {
        $scope.user.password = "";
        $scope.user.password_confirmation = "";
        $scope.user.current_password = "";
    };

    $scope.togglePasswordNotice = function() {
        $scope.showPasswordNotice = $scope.user.email != $scope.originalUser.email;
    };

    $scope.updateAvatar = function() {
        userSettingsService.submitAvatar($scope.avatar.sizes).then(function() {
            $scope.$emit('successMessage', 'Avatar updated successfully.');
            $scope.avatar.changed = false;
        }, function(response) {
            var params = {
                label: 'Error updating avatar',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.updateUserRegistration = function(userDiff) {
        if (!userDiff.email && !userDiff.password) return;
        if (userDiff.email && !userDiff.current_password) {
            var message = {
                type: 'error',
                text: 'You must enter your current password to change your email.'
            };
            $scope.$emit('customMessage', message);
            return;
        }
        userSettingsService.updateUserRegistration(userDiff).then(function() {
            $scope.resetPasswordInputs();
            $scope.$emit('successMessage', 'User registration saved successfully.')
        }, function(response) {
            var params = {
                label: 'Error saving user registration',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.updateUserSettings = function(userDiff) {
        if (!userDiff.title && !userDiff.about_me && !userDiff.settings) return;
        userSettingsService.updateUserSettings(userDiff).then(function() {
            themesService.changeTheme($scope.settings);
            $scope.$emit('successMessage', 'User settings saved successfully.');

            // update `originalUser` to include successfully changed settings
            $scope.originalUser = angular.copy($scope.user);
        }, function(response) {
            var params = {
                label: 'Error saving user settings',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    };

    // saves changed user settings
    $scope.saveChanges = function() {
        // get changed user fields
        var userDiff = objectUtils.getDifferentObjectValues($scope.originalUser, $scope.user);

        // if no fields were changed, inform the user and return
        if (objectUtils.isEmptyObject(userDiff)) {
            if (!$scope.avatar.changed) {
                var message = {type: 'warning', text: 'There are no changes to save.'};
                $scope.$broadcast('message', message);
                return;
            }
        } else {
            // else submit changes to the backend
            $scope.updateUserSettings(userDiff);
            $scope.updateUserRegistration(userDiff);
        }

        // submit avatar if changed
        if ($scope.avatar.changed) {
            $scope.updateAvatar();
        }
    };
});