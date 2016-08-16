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

app.controller('userSettingsController', function($scope, $q, currentUser, activeModList, userObject, userSettingsService, themesService, errorService, tabsFactory, objectUtils) {
    // inherited variables
    $scope.currentUser = currentUser;
    $scope.activeModList = activeModList;
    $scope.permissions = angular.copy(currentUser.permissions);

    // initialize variables
    $scope.user = userObject;
    $scope.settings = userObject.settings;
    $scope.errors = {};
    $scope.tabs = tabsFactory.buildUserSettingsTabs();

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response, $scope.mod.id);
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

    /* settings submission */
    $scope.submit = function() {
        $scope.errors = [];

        //TODO: I feel like this redundancy can be killed
        // @R79: I was thinking the same thing earlier today. -Mator
        userSettingsService.submitUser($scope.user).then(function(data) {
            if (data.status !== "ok") {
                $scope.errors.concat(data.errors);
            }
            $scope.showSuccess = $scope.errors.length == 0;
        });
        userSettingsService.submitUserSettings($scope.userSettings).then(function(data) {
            if (data.status !== "ok") {
                $scope.errors.concat(data.errors);
            } else {
                $scope.showSuccess = $scope.errors.length == 0;
                $scope.updateTheme();
                $scope.$emit('reloadCurrentUser', {});
            }
        });
        if ($scope.avatar.file) {
            userSettingsService.submitAvatar($scope.avatar.file).then(function(data) {
                if (data.status !== "Success") {
                    $scope.errors.push({ message: "Avatar: " + data.status });
                }
                $scope.showSuccess = $scope.errors.length == 0;
            });
        }
    };

    $scope.updateTheme = function() {
        themesService.changeTheme($scope.userSettings.theme);
    }
});