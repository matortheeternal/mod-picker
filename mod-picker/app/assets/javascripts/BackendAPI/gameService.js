app.service('gameService', function(backend, $q) {
    this.retrieveGames = function() {
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
        var availableGames = $q.defer();
        allGames.then(function(games) {
            var availableGameNames = ["Skyrim", "Skyrim SE"];
            var filteredGames = games.filter(function(game) {
                return availableGameNames.indexOf(game.display_name) > -1;
            });
            availableGames.resolve(filteredGames);
        });
        return availableGames.promise;
    };
});
