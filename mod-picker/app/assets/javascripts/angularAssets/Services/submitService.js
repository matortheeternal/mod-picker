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

    this.submit = function (nexus_info, is_utility, has_adult_content) {
        var mod = $q.defer();
        var modData = {
            mod: {
                name: nexus_info.mod_name,
                is_utility: is_utility,
                has_adult_content: has_adult_content,
                game_id: nexus_info.game_id,
                mod_versions: [
                    {
                        released: nexus_info.date_added,
                        obsolete: false,
                        dangerous: false,
                        version: nexus_info.current_version
                    }
                ]
            }
        };
        backend.post('/mods', modData).then(function (data) {
            setTimeout(function () {
                mod.resolve(data);

                // update nexus info to link to the new mod record
                nexus_info.mod_id = mod.id;
                backend.update('/nexus_infos/'+nexus_info.id, {nexus_info: nexus_info});
            }, 1000);
        });
    };
});