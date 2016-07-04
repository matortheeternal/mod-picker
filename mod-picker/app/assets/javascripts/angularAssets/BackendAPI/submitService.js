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

        // prepare required mods
        var required_mods = [];
        mod.requirements.forEach(function(requirement) {
            required_mods.push({
                required_id: requirement.required_id
            })
        });

        // prepare custom sources
        var custom_sources = [];
        customSources.forEach(function(source) {
            custom_sources.push({
                label: source.label,
                url: source.url
            })
        });

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
                asset_paths: mod.analysis.assets,
                plugin_dumps: mod.analysis.plugins,
                custom_sources_attributes: custom_sources,
                required_mods_attributes: required_mods
            }
        };

        // submit mod
        return backend.post('/mods', modData);
    };

    this.updateMod = function(mod, image, sources, customSources) {
        // prepare mod authors
        var mod_auhors = [];
        mod.mod_authors.forEach(function(author) {
            mod_authors.push({
                role: parseInt(author.role),
                user_id: author.user_id
            })
        });

        // prepare required mods
        var required_mods = [];
        mod.requirements.forEach(function(requirement) {
            required_mods.push({
                required_id: requirement.required_id
            })
        });

        // prepare custom sources
        var custom_sources = [];
        customSources.forEach(function(source) {
            custom_sources.push({
                label: source.label,
                url: source.url
            })
        });

        // prepare mod record
        var modData = {
            mod: {
                name: mod.name,
                aliases: mod.aliases,
                authors: mod.authors,
                is_utility: mod.is_utility,
                has_adult_content: mod.has_adult_content,
                game_id: mod.game_id,
                released: mod.released,
                updated: mod.updated,
                primary_category_id: mod.categories[0],
                secondary_category_id: mod.categories[1],
                nexus_info_id: sources.nexus && sources.nexus.id,
                workshop_info_id: sources.workshop && sources.workshop.id,
                lover_info_id: sources.lab && sources.lab.id,
                tag_names: mod.newTags,
                asset_paths: mod.analysis && mod.analysis.assets,
                plugin_dumps: mod.analysis && mod.analysis.plugins,
                image: image.file,
                mod_authors_attributes: mod_auhors,
                custom_sources_attributes: custom_sources,
                required_mods_attributes: required_mods
            }
        };

        // submit mod
        return backend.update('/mods', modData);
    };
});