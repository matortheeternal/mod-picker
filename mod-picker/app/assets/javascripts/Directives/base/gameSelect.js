app.directive('gameSelect', function(formUtils) {
    return {
        priority: 100,
        restrict: 'E',
        templateUrl: '/resources/directives/base/gameSelect.html',
        scope: {
            games: '=',
            selectedGame: '='
        },
        link: formUtils.hideWhenDocumentClicked('showGames'),
        controller: 'gameSelectController'
    }
});

app.controller('gameSelectController', function($scope) {
    $scope.toggleGames = function() {
        $scope.showGames = !$scope.showGames;
    };

    $scope.$on('$stateChangeStart', function() {
        $scope.showGames = false;
    });
});