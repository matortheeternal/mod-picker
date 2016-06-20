app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base', {
        url: '',
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

app.controller('baseController', function($scope, $state, currentUser, games, currentGame) {
    $scope.currentUser = currentUser;
    $scope.permissions = currentUser.permissions;
    $scope.currentGame = currentGame;
    $scope.games = games;

    //reload when the user object is changed in the settings
    $scope.$on('reloadCurrentUser', function() {
        $state.reload();
    });

    $scope.$on("$stateChangeError", function(event, toState, toParams, fromState, fromParams, details) {
        $state.get('base.error').error = {
            event: event,
            toState: toState,
            toParams: toParams,
            fromState: fromState,
            fromParams: fromParams,
            details: details
        };
        $state.go('base.error');
    });
});