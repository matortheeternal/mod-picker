//TODO: change naming
app.service('submitService', function (backend, $q) {
    this.scrapeNexus = function (gameId, nexusId) {
        return backend.retrieve('/nexus_infos/' + nexusId, {game_id: gameId});
    };

    this.verifyPlugins = function (plugins) {
        // TODO: Compute CRC32 of plugin files to verify the backend doesn't already have them
    };

    this.submitMod = function (mod, nexus_info, assets, plugins) {
        // prepare mod record
        mod.name = nexus_info.mod_name;
        mod.game_id = nexus_info.game_id;
        mod.mod_version = {
            mod_id: data.id,
            released: nexus_info.date_added,
            obsolete: false,
            dangerous: false,
            version: nexus_info.current_version
        };
        var modData = {
            mod: mod
        };

        // submit mod
        backend.post('/mods/submit', modData).then(function (data) {
            // update nexus info to link to the mod record
            nexus_info.mod_id = data.id;
            backend.update('/nexus_infos/'+nexus_info.id, {nexus_info: nexus_info});

            // TODO: Submit asset file maps

            // submit plugins
            for (var i = 0; i < plugins.length; i++) {
                plugin = plugins[i];
                backend.postFile('/plugins', 'plugin', plugin).then(function (data) {
                    if (data.status !== 'Success') {
                        alert('Error uploading ' + plugin.name + ': ' + data.status);
                    }
                });
            }
        });
    };
});