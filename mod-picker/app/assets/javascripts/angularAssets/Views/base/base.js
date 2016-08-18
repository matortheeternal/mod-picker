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
            activeModList: function(modListService) {
                return modListService.retrieveActiveModList();
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

app.controller('baseController', function($scope, $rootScope, $state, $window, $timeout, currentUser, activeModList, games, currentGame, categories, categoryPriorities, userService, modListService) {
    // shared variables - used on multiple states.  These have to stored on the
    // $rootScope else we can't modify them for all states
    $rootScope.currentUser = currentUser;
    $rootScope.permissions = currentUser.permissions;
    $rootScope.activeModList = activeModList;
    $rootScope.currentGame = currentGame;
    $rootScope.games = games;
    $rootScope.categories = categories;
    $rootScope.categoryPriorities = categoryPriorities;

    // user selected an option from the my contributions dropdown
    $scope.navigateTo = function(newLocation) {
        $window.location.hash = newLocation;
    };

    // toggle navbar dropdowns
    $scope.toggleDropdown = function($event, key) {
        var showKey = 'show' + key + 'Dropdown';
        $scope[showKey] = !$scope[showKey];
        if (!$scope[showKey]) {
            $event.currentTarget.blur();
        }
    };
    $scope.blurDropdown = function(key) {
        var showKey = 'show' + key + 'Dropdown';
        $timeout(function() {
            $scope[showKey] = false;
        }, 100);
    };

    // user selected to start a new mod list
    $scope.newModList = function() {
        var mod_list = {
            game_id: window._current_game_id,
            name: $rootScope.currentUser.username + "'s Mod List",
            // TODO: Should have a default description set on the backend
            description: "A brand new mod list!"
        };

        modListService.newModList(mod_list, true).then(function(data) {
            $rootScope.activeModList = data.mod_list;
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
            $rootScope.currentUser = currentUser;
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
        var user = $rootScope.currentUser;
        if (endorsed) {
            user.reputation.rep_to_count++;
        } else {
            user.reputation.rep_to_count--;
        }
        var numEndorsed = user.reputation.rep_to_count;
        var rep = user.reputation.overall;
        user.permissions.canEndorse = (rep >= 40 && numEndorsed < 5) || (rep >= 160 && numEndorsed < 10) || (rep >= 640 && numEndorsed < 15);
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