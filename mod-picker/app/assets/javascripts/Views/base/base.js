app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base', {
        url: '',
        redirectTo: 'base.home',
        templateUrl: '/resources/partials/base/base.html',
        controller: 'baseController',
        resolve: {
            userTitles: function(errorService, userTitleService) {
                return errorService.criticalRequest(userTitleService.retrieveUserTitles);
            },
            currentUser: function(errorService, userService) {
                return errorService.criticalRequest(userService.retrieveCurrentUser);
            },
            activeModList: function(errorService, modListService) {
                return errorService.criticalRequest(modListService.retrieveActiveModList);
            },
            currentGame: function(errorService, gameService) {
                return errorService.criticalRequest(gameService.getGameById, window._current_game_id);
            },
            games: function(errorService, gameService) {
                return errorService.criticalRequest(gameService.getAvailableGames);
            },
            categories: function(errorService, categoryService) {
                return errorService.criticalRequest(categoryService.retrieveCategories);
            },
            categoryPriorities: function(errorService, categoryService) {
                return errorService.criticalRequest(categoryService.retrieveCategoryPriorities);
            }
        },
        onEnter: function(themesService, currentUser) {
            themesService.changeTheme(currentUser.settings.theme)
        }
    })
}]);

app.controller('baseController', function($scope, $rootScope, $state, $window, $timeout, currentUser, activeModList, games, currentGame, categories, categoryPriorities, userService) {
    // shared variables - used on multiple states.  These have to stored on the
    // $rootScope else we can't modify them for all states
    $rootScope.currentUser = currentUser;
    $rootScope.permissions = (currentUser && currentUser.permissions) || {};
    $rootScope.activeModList = activeModList;
    $rootScope.currentGame = currentGame;
    $rootScope.games = games;
    $rootScope.categories = categories;
    $rootScope.categoryPriorities = categoryPriorities;

    // load artist credit
    $scope.loadArtistCredit = function() {
        var creditElement = document.getElementById('artist-credit');
        creditElement.className = 'credit-link';
        var afterElement = window.getComputedStyle(creditElement, ':before');
        $scope.creditLink = afterElement.getPropertyValue('content').slice(1, -1);
        creditElement.className = '';
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

    // sets the page title
    $scope.setPageTitle = function(title) {
        var gameName = $rootScope.currentGame.display_name;
        $rootScope.pageTitle = 'Mod Picker: ' + gameName;
        if (title) $rootScope.pageTitle = title + ' | Mod Picker';
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

    $rootScope.$on('themeChanged', function() {
        $timeout(function() {
            $scope.loadArtistCredit();
        }, 500);
    });

    $rootScope.$on('setPageTitle', function(event, title) {
        $scope.setPageTitle(title);
    });

    $scope.loadArtistCredit();
    $scope.setPageTitle();
});