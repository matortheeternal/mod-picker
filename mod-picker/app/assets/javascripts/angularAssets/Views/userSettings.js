/**
 * Created by Sirius on 3/9/2016.
 */
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.settings', {
            templateUrl: '/resources/partials/userSettings/userSettings.html',
            controller: 'userSettingsController',
            url: '/settings',
            redirectTo: 'base.settings.Profile',
        }).state('base.settings.Profile', {
            templateUrl: '/resources/partials/userSettings/profile.html',
            url: '/profile'
        }).state('base.settings.Account', {
            templateUrl: '/resources/partials/userSettings/account.html',
            url: '/account'
        }).state('base.settings.Mod Lists', {
            templateUrl: '/resources/partials/userSettings/modlists.html',
            url: '/mod-lists'
        }).state('base.settings.Authored Mods', {
            templateUrl: '/resources/partials/userSettings/authoredMods.html',
            url: '/authored-mods'
        });
}]);

app.controller('userSettingsController', function ($scope, $q, currentUser, userSettingsService, quoteService, fileUtils, themesService) {
    $scope.userSettings = currentUser.settings;
    $scope.user = currentUser;
    $scope.avatar = {
        src: $scope.user.avatar
    };

    $scope.tabs = [
        {name: 'Profile'},
        {name: 'Account'},
        {name: 'Mod Lists'},
        {name: 'Authored Mods'},
    ];

    // actions the user can or cannot perform
    var rep = $scope.user.reputation.overall;
    $scope.canChangeAvatar = (rep >= 10) || ($scope.user.permissions.isAdmin);
    $scope.canChangeTitle = (rep >= 1280) || ($scope.user.permissions.isAdmin);

    // get random quote for user title
    quoteService.retrieveQuotes().then(function (quotes) {
        var label = $scope.canChangeTitle ? "High Reputation" : "Low Reputation";
        $scope.titleQuote = quoteService.getRandomQuote(quotes, label);
        $scope.titleQuote.text = $scope.titleQuote.text.replace(/Talos/g, $scope.user.username.capitalize());
        $scope.refresh = true;
    });

    /* avatar */
    $scope.browseAvatar = function() {
        document.getElementById('avatar-input').click();
    };

    $scope.resetAvatar = function() {
        $scope.avatar.file = null;
        $scope.avatar.src = $scope.user.avatar;
        $scope.$apply();
    };

    $scope.changeAvatar = function(event) {
        $scope.errors = [];
        if (event.target.files && event.target.files[0]) {
            var avatarFile = event.target.files[0];

            // check file type
            var ext = fileUtils.getFileExtension(avatarFile.name);
            if ((ext !== 'png') && (ext !== 'jpg')) {
                $scope.errors.push({message: "Unsupported file type.  Avatar image must be a PNG or JPG file." });
                $scope.resetAvatar();
                return;
            }

            // check filesize
            if (avatarFile.size > 1048576) {
                $scope.errors.push({message: "Avatar image is too big.  Maximum file size 1.0MB." });
                $scope.resetAvatar();
                return;
            }

            // check dimensions
            var img = new Image();
            img.onload = function() {
                //alert("Image loaded!");
                var imageTooBig = (img.width > 250) || (img.height > 250);
                if (imageTooBig) {
                    $scope.errors.push({message: "Avatar image too large.  Maximum dimensions 250x250." });
                    $scope.resetAvatar();
                } else {
                    $scope.avatar.file = avatarFile;
                    $scope.avatar.src = img.src;
                    $scope.$apply();
                }
            };
            img.src = URL.createObjectURL(avatarFile);
        } else if ($scope.user) {
            $scope.resetAvatar();
        }
    };


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
            $scope.user.showSuccess = $scope.errors.length == 0;
        });
        userSettingsService.submitUserSettings($scope.userSettings).then(function (data) {
            if (data.status !== "ok") {
                $scope.errors.concat(data.errors);
            } else {
                $scope.user.showSuccess = $scope.errors.length == 0;
                themesService.changeTheme($scope.userSettings.theme);
            }
        });
        if ($scope.avatar.file) {
            userSettingsService.submitAvatar($scope.avatar.file).then(function (data) {
                if (data.status !== "Success") {
                    $scope.errors.push({message: "Avatar: " + data.status});
                }
                $scope.user.showSuccess = $scope.errors.length == 0;
            });
        }
    };
});
