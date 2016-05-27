app.service('gameService', function (backend, $q) {
    this.retrieveGames = function () {
        return backend.retrieve('/games');
    };

    var allGames = this.retrieveGames();

    this.getGameById = function ($q, id) {
        var output = $d.defer();
        allGames.then(function(games) {
            output.resolve(games.find(function(game) {
                return game.id == id;
            }));
        });
        return output.promise;
    };
});
