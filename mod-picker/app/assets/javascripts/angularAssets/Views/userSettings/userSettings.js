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
                templateUrl: '/resources/partials/userSettings/modlists.html',
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
    });
}]);

app.controller('userSettingsController', function($scope, $rootScope, $q, userObject, userSettingsService, themesService, errorService, tabsFactory, objectUtils) {
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

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response);
        errors.forEach(function(error) {
            $scope.$broadcast('message', error);
        });
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display success message
    $scope.$on('successMessage', function(event, text) {
        var successMessage = { type: "success", text: text };
        $scope.$broadcast('message', successMessage);
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display custom message
    $scope.$on('customMessage', function(event, message) {
        $scope.$broadcast('message', message);
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    $scope.saveChanges = function() {
        // get changed user fields
        var userDiff = objectUtils.getDifferentObjectValues($scope.originalUser, $scope.user);

        // if no fields were changed, inform the user and return
        if (objectUtils.isEmptyObject(userDiff)) {
            if (!$scope.avatar || !$scope.avatar.file) {
                var message = {type: 'warning', text: 'There are no changes to save.'};
                $scope.$broadcast('message', message);
                return;
            }
        }
        // else submit changes to the backend
        else {
            userSettingsService.updateUserSettings(userDiff).then(function () {
                themesService.changeTheme($scope.settings.theme);
                $scope.$emit('successMessage', 'User settings saved successfully.')
            }, function (response) {
                var params = {
                    label: 'Error saving user settings',
                    response: response
                };
                $scope.$emit('errorMessage', params);
            });
        }

        // submit avatar if changed
        if ($scope.avatar && $scope.avatar.file) {
            userSettingsService.submitAvatar($scope.avatar.file).then(function() {
                $scope.$emit('successMessage', 'Avatar updated successfully.')
            }, function(response) {
                var params = {
                    label: 'Error updating avatar',
                    response: response
                };
                $scope.$emit('errorMessage', params);
            });
        }
    };
});