/**
 * Created by Sirius on 3/9/2016.
 */
app.config(['$routeProvider', function ($routeProvider) {

    $routeProvider.when('/settings', {
            templateUrl: '/resources/partials/userSettings/userSettings.html',
            controller: 'userSettingsController'
        }
    );
}]);

app.controller('userSettingsController', function ($scope, $q, userSettingsService, userService, quoteService) {
    useTwoColumns(false);

    $scope.tabs = [
        { name: 'Profile', url: '/resources/partials/userSettings/profile.html'},
        { name: 'Account', url: '/resources/partials/userSettings/account.html'},
        { name: 'Mod Lists', url: '/resources/partials/userSettings/modlists.html'},
        { name: 'Authored Mods', url: '/resources/partials/userSettings/authoredMods.html'}
    ];

    $scope.currentTab = $scope.tabs[0];

    userSettingsService.retrieveUserSettings().then(function (userSettings) {
        $scope.userSettings = userSettings;
        userService.retrieveUser(userSettings.user_id).then(function (user) {
            $scope.user = user;
            $scope.avatar = {
                src: $scope.user.avatar
            };

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

            // get random quote for user title
            quoteService.retrieveQuotes().then(function (quotes) {
                var label = ($scope.user.reputation.overall < 1280) ? "Low Reputation" : "High Repution";
                $scope.titleQuote = quoteService.getRandomQuote(quotes, label);
            });
        });
    });

    /* avatar */
    $scope.browseAvatar = function() {
        document.getElementById('avatar-input').click();
    };

    $scope.changeAvatar = function(event) {
        if (event.target.files && event.target.files[0]) {
            $scope.avatar.file = event.target.files[0];
            var reader = new FileReader();
            reader.onload = function (e) {
                $scope.avatar.src = e.target.result;
                $scope.$apply();
            };
            reader.readAsDataURL($scope.avatar.file);
        } else if ($scope.user) {
            $scope.avatar.src = $scope.user.avatar;
            $scope.$apply();
        }
    };

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
                $scope.errors.push({message: data.status });
            }
        });
    };

    /* settings submission */
    $scope.submit = function() {
        $scope.errors = [];
        userSettingsService.submitUser($scope.user).then(function (data) {
            if (data.status === "ok" && !$scope.errors.length) {
                $scope.showSuccess = true;
            }
            else {
                $scope.errors.concat(data.errors);
            }
        });
        userSettingsService.submitUserSettings($scope.userSettings).then(function (data) {
            if (data.status === "ok" && !$scope.errors.length) {
                $scope.showSuccess = true;
            }
            else {
                $scope.errors.concat(data.errors);
            }
        });
        if ($scope.avatar.file) {
            userSettingsService.submitAvatar($scope.avatar.file).then(function (data) {
                if (data.status === "Success") {
                    $scope.showSuccess = true;
                }
                else {
                    $scope.errors.push({message: data.status});
                }
            });
        }
    };
});
