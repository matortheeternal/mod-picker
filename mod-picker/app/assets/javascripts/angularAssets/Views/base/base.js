app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base', {
        url: '',
        redirectTo: 'base.home',
        templateUrl: '/resources/partials/base/base.html',
        controller: 'baseController',
        resolve: {
            currentUser: function(userService) {
                return userService.retrieveCurrentUser();
            },
            currentGame: function(gameService) {
                return gameService.getGameById(window._current_game_id);
            },
            games: function(gameService) {
                return gameService.getAvailableGames();
            },
            categories: function(categoryService) {
                return categoryService.retrieveCategories();
            },
            categoryPriorities: function(categoryService) {
                return categoryService.retrieveCategoryPriorities();
            }
        },
        onEnter: function(themesService, currentUser) {
            themesService.changeTheme(currentUser.settings.theme)
        }
    })
}]);

app.controller('baseController', function($scope, $state, $location, currentUser, games, currentGame, userService, modListService) {
    $scope.currentUser = currentUser;
    $scope.permissions = currentUser.permissions;
    $scope.activeModList = currentUser.active_mod_list;
    $scope.currentGame = currentGame;
    $scope.games = games;

    // user selected an option from the my contributions dropdown
    $scope.navigateTo = function(newLocation) {
        $location.path(newLocation);
    };

    // user selected to start a new mod list
    $scope.newModList = function() {
        var mod_list = {
            game_id: window._current_game_id,
            name: $scope.currentUser.username + "'s Mod List",
            // TODO: Should have a default description set on the backend
            description: "A brand new mod list!"
        };

        modListService.newModList(mod_list, true).then(function(data) {
            $scope.activeModList = data.mod_list;
            $state.go('base.mod-list', {modListId: data.mod_list.id});
        }, function(response) {
            $state.get('base.error').error = {
                text: 'Error creating new mod list.',
                response: response,
                stateName: 'base',
                stateUrl: window.location.hash
            };
            $state.go('base.error');
        });
    };

    //reload when the user object is changed in the settings
    $scope.retrieveCurrentUser = function(callback) {
        userService.retrieveCurrentUser().then(function(currentUser) {
            $scope.currentUser = currentUser;
            callback && callback();
        }, function(response) {
            $state.get('base.error').error = {
                text: 'Error retrieving current user.',
                response: response,
                stateName: 'base',
                stateUrl: window.location.hash
            };
            $state.go('base.error');
        });
    };

    $scope.$on('reloadCurrentUser', function() {
        $scope.retrieveCurrentUser();
    });

    $scope.$on('updateRepPermissions', function(event, endorsed) {
        //if the user was just endorsed
        if (endorsed) {
            currentUser.reputation.rep_to_count++;
        } else {
            currentUser.reputation.rep_to_count--;
        }
        var numEndorsed = currentUser.reputation.rep_to_count;
        var rep = currentUser.reputation.overall;
        currentUser.permissions.canEndorse = (rep >= 40 && numEndorsed < 5) || (rep >= 160 && numEndorsed < 10) || (rep >= 640 && numEndorsed < 15);
    });

    // handle state change errors
    $scope.$on("$stateChangeError", function(event, toState, toParams, fromState, fromParams, error) {
        $state.get('base.error').error = error;
        $state.go('base.error');
    });
});

app.controller('searchController', function($scope, $state) {
    $scope.loading = false;
    $scope.processSearch = function() {
        $state.go("base.mods", {q: $scope.search}, {notify: true});
    };
});