app.service('scrapeService', function(backend) {
    this.scrapeNexus = function(gameId, modId) {
        return backend.retrieve('/nexus_infos/' + modId, {game_id: gameId});
    };
    this.scrapeLab = function(modId) {
        return backend.retrieve('/lover_infos/' + modId);
    };
    this.scrapeWorkshop = function(modId) {
        return backend.retrieve('/workshop_infos/' + modId);
    };
});