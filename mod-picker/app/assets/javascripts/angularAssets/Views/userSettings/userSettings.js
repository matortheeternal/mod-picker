/**
 * Created by Sirius on 3/9/2016.
 */
app.config(['$stateProvider', function($stateProvider) {
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
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Profile': {
                templateUrl: '/resources/partials/userSettings/profile.html',
                controller: 'userSettingsProfileController',
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
        url: 'profile'
    }).state('base.settings.Account', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Account': {
                templateUrl: '/resources/partials/userSettings/account.html',
            }
        },
        url: '/account'
    }).state('base.settings.Mod Lists', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Mod Lists': {
                templateUrl: '/resources/partials/userSettings/modlists.html',
            }
        },
        url: '/mod-lists'
    }).state('base.settings.Authored Mods', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Authored Mods': {
                templateUrl: '/resources/partials/userSettings/authoredMods.html',
            }
        },
        url: '/mods'
    });
}]);

app.controller('userSettingsController', function($scope, $q, userObject, currentUser, userSettingsService, fileUtils, themesService) {
    $scope.userSettings = currentUser.settings;
    $scope.user = userObject.user;
    $scope.avatar = {
        src: $scope.user.avatar
    };
    $scope.permissions = angular.copy(currentUser.permissions);

    $scope.tabs = [
        { name: 'Profile' },
        { name: 'Account' },
        { name: 'Mod Lists' },
        { name: 'Authored Mods' }
    ];

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

app.controller('userSettingsProfileController', function($scope, titleQuote) {
    $scope.titleQuote = titleQuote;
    $scope.avatar = {
        src: $scope.user.avatar
    };

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
                $scope.errors.push({ message: "Unsupported file type.  Avatar image must be a PNG or JPG file." });
                $scope.resetAvatar();
                return;
            }

            // check filesize
            if (avatarFile.size > 1048576) {
                $scope.errors.push({ message: "Avatar image is too big.  Maximum file size 1.0MB." });
                $scope.resetAvatar();
                return;
            }

            // check dimensions
            var img = new Image();
            img.onload = function() {
                //alert("Image loaded!");
                var imageTooBig = (img.width > 250) || (img.height > 250);
                if (imageTooBig) {
                    $scope.errors.push({ message: "Avatar image too large.  Maximum dimensions 250x250." });
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
});
