app.service('gameService', function (backend, $q) {
    this.retrieveGames = function () {
        return backend.retrieve('/games');
    };

    this.getGameById = function (games, id) {
        return games.find(function(game) {
            return game.id == id;
        })
    };
});