app.controller('globalController', function($scope, $rootScope, userService, themesService, gameService) {
    $scope.permissions = {
        isAdmin: false,
        isModerator: false,
        canSubmitMod: false
    };

    userService.retrieveCurrentUser().then(function(user) {
        $scope.currentUser = user;
        themesService.changeTheme(user.settings.theme);
        // figure out user permissions
        var permissions = $scope.permissions;
        permissions.isAdmin = user.role === 'admin';
        permissions.isModerator = user.role === 'moderator';
        // TODO: Remove this when beta is over
        permissions.canSubmitMod = true;
        //permissions.canSubmitMod = permissions.isAdmin || permissions.isModerator || user.reputation.overall > 160;
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