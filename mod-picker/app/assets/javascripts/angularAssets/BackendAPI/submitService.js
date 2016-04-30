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

    this.submitMod = function (mod, analysis, sources) {
        // select primary source
        var primarySource = sources.nexus || sources.workshop || sources.lab;
        var currentVersion = primarySource.current_version || 'LATEST';

        // prepare mod record
        var modData = {
            mod: {
                name: primarySource.mod_name,
                is_utility: mod.is_utility,
                has_adult_content: mod.has_adult_content,
                game_id: mod.game_id,
                released: primarySource.date_submitted,
                primary_category_id: mod.categories[0],
                secondary_category_id: mod.categories[1],
                nexus_info_id: sources.nexus.id,
                workshop_info_id: sources.workshop.id,
                lover_info_id: sources.lab.id,
                assets: analysis.assets,
                plugins: analysis.plugins,
                mod_versions_attributes: [{
                    released: primarySource.date_updated,
                    version: currentVersion
                }]
            }
        };

        // submit mod
        return backend.post('/mods/submit', modData);
    };
});