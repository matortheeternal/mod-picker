app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base', {
        abstract: true,
        template: '<ui-view/>',
        resolve: {
            currentUser: function(userService) {
                return userService.retrieveCurrentUser();
            },
            currentGame: function(gameService) {
                return gameService.getGameById(window._current_game_id);
            }
        },
        onEnter: function(themesService, currentUser) {
            themesService.changeTheme(currentUser.settings.theme)
        }
    })
}]);
