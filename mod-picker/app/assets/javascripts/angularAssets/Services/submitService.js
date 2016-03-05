app.service('submitService', function (backend, $q) {
    this.scrapeNexus = function (gameId, nexusId) {
        var nexusInfo = $q.defer();
        backend.retrieve('/nexus_infos/' + nexusId, {game_id: gameId}).then(function (data) {
            setTimeout(function () {
                nexusInfo.resolve(data);
            }, 1000);
        });
        return nexusInfo.promise;
    };
});