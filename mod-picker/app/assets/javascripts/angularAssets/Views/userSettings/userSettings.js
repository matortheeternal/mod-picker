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
                user: function(userService, currentUser) {
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
        }).state('base.settings.Authored Mods', {
            templateUrl: '/resources/partials/userSettings/authoredMods.html',
            url: '/mods'
        });
}]);

app.controller('userSettingsController', function ($scope, $q, user, currentUser, userSettingsService, fileUtils, themesService) {
    $scope.userSettings = currentUser.settings;
    $scope.user = user;
    $scope.avatar = {
        src: $scope.user.avatar
    };
    $scope.permissions = currentUser.permissions;

    $scope.tabs = [
        {name: 'Profile'},
        {name: 'Account'},
        {name: 'Mod Lists'},
        {name: 'Authored Mods'}
    ];


    //TODO: I think we should put the modlist actions inside somewhere reusable (directive)
    /* mod list actions */
    $scope.editModList = function(modlist) {
        //TODO: I'm not sure if this state.go is correct, the param might be off
        $state.go(base.modlist, {modlistId: modlist.id})
    };

    $scope.appendModList = function(data) {
        var modlists = $scope.user.mod_lists;
        if (data.modlist) {
            modlists.push(data.modlist);
            if (data.modlist.is_collection) {
                $scope.collections.push(data.modlist);
            } else {
                $scope.lists.push(data.modlist);
            }
            $scope.$apply();
        } else {
            $scope.errors.push({message: "Didn't receive a cloned mod list from the server"});
        }
    };

    $scope.cloneModList = function(modlist) {
        console.log('Clone Mod List: "'+modlist.name+'"');
        $scope.errors = [];
        userSettingsService.cloneModList(modlist).then(function (data) {
            if (data.status === "ok") {
                $scope.appendModList(data);
            } else {
                $scope.errors.push(data.status);
            }
        });
    };

    $scope.removeModList = function(modlist) {
        var modlists = $scope.user.mod_lists;
        var index = modlists.indexOf(modlist);
        modlists.splice(index, 1);
        if (modlist.is_collection) {
            index = $scope.collections.indexOf(modlist);
            $scope.collections.splice(index, 1);
        } else {
            index = $scope.lists.indexOf(modlist);
            $scope.lists.splice(index, 1);
        }
        $scope.$apply();
    };

    $scope.deleteModList = function(modlist) {
        console.log('Delete Mod List: "'+modlist.name+'"');
        $scope.errors = [];
        userSettingsService.deleteModList(modlist).then(function (data) {
            if (data.status === "ok") {
                $scope.removeModList(modlist);
            } else {
                $scope.errors.push({message: "Delete Mod List: " + data.status });
            }
        });
    };

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
