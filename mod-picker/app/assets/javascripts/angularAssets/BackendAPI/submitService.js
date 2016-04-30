//TODO: change naming
app.service('submitService', function (backend, $q) {
    this.scrapeNexus = function (gameId, modId) {
        return backend.retrieve('/nexus_infos/' + modId, {game_id: gameId});
    };
    this.scrapeLab = function (modId) {
        return backend.retrieve('/lover_infos/' + modId);
    };
    this.scrapeWorkshop = function (modId) {
        return backend.retrieve('/workshop_infos/' + modId);
    };

    this.verifyPlugins = function (plugins) {
        // TODO: Compute CRC32 of plugin files to verify the backend doesn't already have them
    };

    this.submitMod = function (mod, nexus_info, assets, plugins) {
        // prepare mod record
        var modData = {
            mod: {
                name: nexus_info.mod_name,
                is_utility: is_utility,
                has_adult_content: has_adult_content,
                game_id: nexus_info.game_id,
                released: nexus_info.date_added,
                primary_category_id: mod.categories[0],
                secondary_category_id: mod.categories[1],
                nexus_info_id: nexus_info.id,
                assets: mod.assets,
                mod_versions_attributes: [{
                    released: nexus_info.date_added,
                    version: nexus_info.current_version
                }]
            }
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