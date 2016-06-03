app.controller('globalController', function($scope, $rootScope, userService, themesService, gameService) {
    $scope.permissions = {
        isAdmin: false,
        isModerator: false,
        canSubmitMod: false
    };

    userService.retrieveCurrentUser().then(function(user) {
        $scope.currentUser = user;
        $scope.permissions = userService.getPermissions(user);
        themesService.changeTheme(user.settings.theme);
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

    $scope.$on('reloadCurrentUser', function() {
        userService.retrieveCurrentUser().then(function (user) {
            $scope.currentUser = user;
        });
    });
});