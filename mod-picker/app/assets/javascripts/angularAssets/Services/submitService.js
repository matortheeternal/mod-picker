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
        mod.primary_category_id = mod.categories[0];
        mod.secondary_category_id = mod.categories[1];
        mod.assets = assets;
        mod.nexus_info_id = nexus_info.id;
        mod.mod_versions_attributes = [{
            released: nexus_info.date_added,
            version: nexus_info.current_version
        }];
        var modData = {
            mod: mod
        };

        // submit mod
        backend.post('/mods/submit', modData).then(function (data) {
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