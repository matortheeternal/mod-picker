//TODO: change naming
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

    this.verifyPlugins = function (plugins) {
        // TODO: Compute CRC32 of plugin files to verify the backend doesn't already have them
    };

    this.submit = function (nexus_info, is_utility, has_adult_content, plugins) {
        var modData = {
            mod: {
                name: nexus_info.mod_name,
                is_utility: is_utility,
                has_adult_content: has_adult_content,
                game_id: nexus_info.game_id
            }
        };
        backend.post('/mods', modData).then(function (data) {
            setTimeout(function () {
                // update nexus info to link to the mod record
                nexus_info.mod_id = data.id;
                backend.update('/nexus_infos/'+nexus_info.id, {nexus_info: nexus_info});

                // create mod version record linking to the mod record
                modVersionData = {
                    mod_version: {
                        mod_id: data.id,
                        released: nexus_info.date_added,
                        obsolete: false,
                        dangerous: false,
                        version: nexus_info.current_version
                    }
                };
                backend.post('/mod_versions', modVersionData);

                // submit plugins
                for (var i = 0; i < plugins.length; i++) {
                    plugin = plugins[i];
                    backend.postFile('/plugins', 'plugin', plugin).then(function (data) {
                        if (data.status !== 'Success') {
                            alert('Error uploading ' + plugin.name + ': ' + data.status);
                        }
                    });
                }
            }, 1000);
        });
    };
});