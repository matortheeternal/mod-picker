app.service('gameService', function (backend, $q) {
    this.retrieveGames = function () {
        return backend.retrieve('/games');
    };

    this.getGameById = function (games, id) {
        return games.find(function(game) {
            return game.id == id;
        })
    };

    this.getAvailableGames = function(games) {
        var availableGames = ["Skyrim"];
        return games.filter(function(game) {
            return availableGames.indexOf(game.display_name) > -1;
        });
    };
});