app.directive('gameSelect', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/gameSelect.html',
        scope: {
            games: '=',
            selectedGame: '='
        },
        controller: 'gameSelectController'
    }
});

app.controller('gameSelectController', function ($scope) {
    $scope.changeGame = function() {
        window.location = '/' + $scope.selectedGame.nexus_name;
    };
});