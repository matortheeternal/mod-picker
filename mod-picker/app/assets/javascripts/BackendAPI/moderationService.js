app.service('moderationService', function(backend) {
    this.retrieveStats = function() {
        return backend.retrieve("/moderator_cp");
    };
});
