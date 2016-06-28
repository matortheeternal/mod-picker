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

    this.submitMod = function (mod, sources, customSources) {
        // helper variables
        var requirements = mod.requirements;
        var analysis = mod.analysis;

        // load earliest date released and latest date updated from sources
        var released = mod.released;
        var updated = mod.updated;
        for (var property in sources) {
            if (sources.hasOwnProperty(property) && sources[property]) {
                var source = sources[property];
                if (!released || source.released < released) {
                    released = source.released;
                }
                if (!updated || source.updated > updated) {
                    updated = source.updated;
                }
            }
        }

        // prepare mod record
        var modData = {
            mod: {
                name: mod.name,
                aliases: mod.aliases,
                authors: mod.authors,
                is_utility: mod.is_utility,
                has_adult_content: mod.has_adult_content,
                game_id: mod.game_id,
                released: released || DateTime.now(),
                updated: updated,
                primary_category_id: mod.categories[0],
                secondary_category_id: mod.categories[1],
                nexus_info_id: sources.nexus && sources.nexus.id,
                workshop_info_id: sources.workshop && sources.workshop.id,
                lover_info_id: sources.lab && sources.lab.id,
                tag_names: mod.tags,
                asset_paths: analysis.assets,
                plugin_dumps: analysis.plugins,
                custom_sources_attributes: customSources,
                required_mods_attributes: requirements
            }
        };

        // submit mod
        return backend.post('/mods', modData);
    };
});