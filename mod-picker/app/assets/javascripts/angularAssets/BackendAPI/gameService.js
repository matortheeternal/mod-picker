app.service('gameService', function (backend, $q) {
    this.retrieveGames = function () {
        return backend.retrieve('/games', {cache: true});
    };

    var allGames = this.retrieveGames();

    this.getGameById = function(id) {
        var game = $q.defer();
        allGames.then(function(games) {
            game.resolve(games.find(function(data) {
                return data.id == id;
            }));
        });
        return game.promise;
    };

    this.getAvailableGames = function() {
        var output = $q.defer();
        allGames.then(function(games) {
            var availableGames = ["Skyrim"];
            output.resolve(
                games.filter(function(game) {
                    return availableGames.indexOf(game.display_name) > -1;
                })
            );
        });
        return output.promise;
    };
});
