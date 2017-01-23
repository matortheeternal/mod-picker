app.service('moderationService', function(backend) {
    this.retrieveStats = function() {
        return backend.retrieve("/moderator_cp", {
            game: window._current_game_id
        });
    };
});
