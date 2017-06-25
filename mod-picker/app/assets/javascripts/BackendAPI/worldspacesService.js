app.service('worldspacesService', function(backend) {
    this.retrieveWorldspaces = function () {
        var params = {game: window._current_game_id};
        return backend.retrieve('/worldspaces.json', params);
    };
});