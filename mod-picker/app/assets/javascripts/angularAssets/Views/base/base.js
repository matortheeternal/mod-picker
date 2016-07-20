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
            }
        },
        onEnter: function(themesService, currentUser) {
            themesService.changeTheme(currentUser.settings.theme)
        }
    })
}]);

app.controller('baseController', function($scope, $state, $location, currentUser, games, currentGame) {
    $scope.currentUser = currentUser;
    $scope.permissions = currentUser.permissions;
    $scope.currentGame = currentGame;
    $scope.games = games;

    // user selected an option from the my contributions dropdown
    $scope.navigateTo = function(newLocation) {
        $location.path(newLocation);
    };

    //reload when the user object is changed in the settings
    $scope.$on('reloadCurrentUser', function() {
        $state.reload();
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