/**
 * Created by Sirius on 3/9/2016.
 */
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.settings', {
            templateUrl: '/resources/partials/userSettings/userSettings.html',
            controller: 'userSettingsController',
            url: '/settings',
            redirectTo: 'base.settings.Profile',
            resolve: {
                userObject: function(userService, currentUser) {
                    return userService.retrieveUser(currentUser.id);
                }
            }
        }).state('base.settings.Profile', {
            templateUrl: '/resources/partials/userSettings/profile.html',
            controller: 'userSettingsProfileController',
            url: '/profile',
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
            }
        }).state('base.settings.Account', {
            templateUrl: '/resources/partials/userSettings/account.html',
            url: '/account'
        }).state('base.settings.Mod Lists', {
            templateUrl: '/resources/partials/userSettings/modlists.html',
            url: '/mod-lists'
        }).state('base.settings.Collections', {
            templateUrl: '/resources/partials/userSettings/collections.html',
            url: '/collections'
        }).state('base.settings.Authored Mods', {
            templateUrl: '/resources/partials/userSettings/authoredMods.html',
            url: '/mods'
        });
}]);

app.controller('userSettingsController', function ($scope, $q, userObject, currentUser, userSettingsService, fileUtils, themesService) {
    $scope.userSettings = currentUser.settings;
    $scope.user = userObject.user;
    $scope.avatar = {
        src: $scope.user.avatar
    };
    $scope.permissions = currentUser.permissions;

    $scope.tabs = [
        {name: 'Profile'},
        {name: 'Account'},
        {name: 'Mod Lists'},
        {name: 'Collections'},
        {name: 'Authored Mods'}
    ];

    /* settings submission */
    $scope.submit = function() {
        $scope.errors = [];

        //TODO: I feel like this redundancy can be killed
        // @R79: I was thinking the same thing earlier today. -Mator
        userSettingsService.submitUser($scope.user).then(function (data) {
            if (data.status !== "ok") {
                $scope.errors.concat(data.errors);
            }
            $scope.showSuccess = $scope.errors.length == 0;
        });
        userSettingsService.submitUserSettings($scope.userSettings).then(function (data) {
            if (data.status !== "ok") {
                $scope.errors.concat(data.errors);
            } else {
                $scope.showSuccess = $scope.errors.length == 0;
                $scope.updateTheme();
                $scope.$emit('reloadCurrentUser', {});
            }
        });
        if ($scope.avatar.file) {
            userSettingsService.submitAvatar($scope.avatar.file).then(function (data) {
                if (data.status !== "Success") {
                    $scope.errors.push({message: "Avatar: " + data.status});
                }
                $scope.showSuccess = $scope.errors.length == 0;
            });
        }
    };

    $scope.updateTheme = function() {
        themesService.changeTheme($scope.userSettings.theme);
    }
});

app.controller('userSettingsProfileController', function ($scope, titleQuote) {
    $scope.titleQuote = titleQuote;
});
