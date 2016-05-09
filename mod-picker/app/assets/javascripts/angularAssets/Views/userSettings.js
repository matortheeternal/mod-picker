/**
 * Created by Sirius on 3/9/2016.
 */
app.config(['$stateProvider', function ($stateProvider) {

    $stateProvider.state('settings', {
            templateUrl: '/resources/partials/userSettings/userSettings.html',
            controller: 'userSettingsController',
            url: '/settings'
        }
    );
}]);

app.controller('userSettingsController', function ($scope, $q, userSettingsService, userService, quoteService, userTitleService, fileUtils, themesService) {

    //TODO: put this into the Routing logic
    $scope.tabs = [
        { name: 'Profile', url: '/resources/partials/userSettings/profile.html'},
        { name: 'Account', url: '/resources/partials/userSettings/account.html'},
        { name: 'Mod Lists', url: '/resources/partials/userSettings/modlists.html'},
        { name: 'Authored Mods', url: '/resources/partials/userSettings/authoredMods.html'}
    ];

    $scope.currentTab = $scope.tabs[0];

    //TODO: put this into a service
    // A service which calls other services and sets scope variables?
    // seems odd to me.  -Mator
    userSettingsService.retrieveUserSettings().then(function (userSettings) {
        $scope.userSettings = userSettings;
        //Don't trust the server! (actually, this is just to make sure that caching usersettings doesn't screws us over)
        //this obviously belongs into a service, do note that todo above this
        $scope.userSettings.theme = themesService.getTheme();
        //TODO: I feel like this could be put inside the retrieveUserSettings() function
        userService.retrieveUser(userSettings.user_id).then(function (user) {
            $scope.user = user;
            $scope.avatar = {
                src: $scope.user.avatar
            };

            // actions the user can or cannot perform
            var rep = $scope.user.reputation.overall;
            $scope.canChangeAvatar = (rep >= 10) || ($scope.user.role === 'admin');
            $scope.canChangeTitle = (rep >= 1280) || ($scope.user.role === 'admin');

            //splitting the modlists into collections and non collections
            //sorry taffy, this logic should be in a service right? -Sirius
            modlists = $scope.user.mod_lists;
            $scope.lists = [];
            $scope.collections = [];
            modlists.forEach(function (modlist) {
                if (modlist.is_collection) {
                    $scope.collections.push(modlist);
                }
                else {
                    $scope.lists.push(modlist);
                }
            });

            // get user title if not custom
            if (!$scope.user.title) {
                userTitleService.retrieveUserTitles().then(function (titles) {
                    var gameTitles = userTitleService.getSortedGameTitles(titles);
                    $scope.user.title = userTitleService.getUserTitle(gameTitles, rep);
                });
            }

            // get random quote for user title
            quoteService.retrieveQuotes().then(function (quotes) {
                var label = $scope.canChangeTitle ? "High Reputation" : "Low Reputation";
                $scope.titleQuote = quoteService.getRandomQuote(quotes, label);
                $scope.titleQuote.text = $scope.titleQuote.text.replace(/Talos/g, $scope.user.username.capitalize());
                $scope.refresh = true;
            });
        });
    });

    //TODO: I think we should put the modlist actions inside somewhere reusable (directive)
    /* mod list actions */
    $scope.editModList = function(modlist) {
        console.log('Edit Mod List: "'+modlist.name+'"');
        window.location = '#/modlists/' + modlist.id;
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
                themesService.changeTheme($scope.userSettings.theme);
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
});
