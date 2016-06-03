app.controller('globalController', function($scope, $rootScope, userService, themesService, gameService) {

    userService.retrieveCurrentUser().then(function(data) {
        $scope.currentUser = data;
        themesService.changeTheme(data.settings.theme);
    });

    gameService.retrieveGames().then(function(data) {
        $scope.games = data;
        $scope.currentGame = $scope.games.find(function(game) {
            return game.id == window._current_game_id;
        });
    });

    $rootScope.$on('themeChanged', function (event, newTheme) {
        $scope.currentTheme = newTheme;
    });
});