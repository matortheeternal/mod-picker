app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base', {
        url: '',
        views: {
            'header': {
                templateUrl: '/resources/partials/header.html',
                controller: 'headerController',
                resolve: {
                    games: function(gameService) {
                        return gameService.getAllGames();
                    }
                }
            },
            'nav': {
                templateUrl: '/resources/partials/nav.html',
                controller: 'navController'
            },
            'footer': {
                templateUrl: '/resources/partials/footer.html'
            },
            'content': {
                template: '<ui-view/>'
            }
        },
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

app.controller('globalController', function($state) {

    //reload when the user object is changed in the settings
    $scope.$on('reloadCurrentUser', function() {
        $state.reload();
    });
});

app.controller('headerController', function($scope, currentUser, games) {
    $scope.currentUser = currentUser;
    $scope.games = games;
});

app.controller('navController', function($scope, currentUser) {
    $scope.currentUser = currentUser;
    $scope.permissions = currentUser.permissions;
});
