//TODO: change naming
app.service('submitService', function (backend, objectUtils) {
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
                tag_names: mod.newTags,
                asset_paths: mod.analysis.assets,
                plugin_dumps: mod.analysis.plugins,
                custom_sources_attributes: custom_sources,
                required_mods_attributes: required_mods
            }
        };

        // submit mod
        return backend.post('/mods', modData);
    };

    this.updateMod = function(mod, sources, customSources) {
        // prepare mod authors
        if (mod.mod_authors) {
            var mod_authors = [];
            mod.mod_authors.forEach(function(author) {
                if (author._destroy) {
                    mod_authors.push({
                        id: author.id,
                        _destroy: true
                    })
                } else if (author.id) {
                    mod_authors.push({
                        id: author.id,
                        role: author.role
                    })
                } else {
                    mod_authors.push({
                        role: author.role,
                        user_id: author.user_id
                    })
                }
            });
        }

        // prepare required mods
        if (mod.requirements) {
            var required_mods = [];
            mod.requirements.forEach(function(requirement) {
                if (requirement._destroy) {
                    required_mods.push({
                        id: requirement.id,
                        _destroy: true
                    })
                } else {
                    required_mods.push({
                        required_id: requirement.required_id
                    })
                }
            });
        }

        // prepare custom sources
        var custom_sources = [];
        customSources.forEach(function(source) {
            custom_sources.push({
                id: source.id,
                label: source.label,
                url: source.url,
                _destroy: source._destroy
            })
        });

        // prepare mod record
        var modData = {
            mod: {
                id: mod.id,
                name: mod.name,
                aliases: mod.aliases,
                authors: mod.authors,
                is_utility: mod.is_utility,
                has_adult_content: mod.has_adult_content,
                game_id: mod.game_id,
                released: mod.released,
                updated: mod.updated,
                primary_category_id: mod.primary_category_id,
                secondary_category_id: mod.secondary_category_id,
                nexus_info_id: sources.nexus && sources.nexus.id,
                workshop_info_id: sources.workshop && sources.workshop.id,
                lover_info_id: sources.lab && sources.lab.id,
                tag_names: mod.newTags,
                asset_paths: mod.analysis && mod.analysis.assets,
                plugin_dumps: mod.analysis && mod.analysis.plugins,
                mod_authors_attributes: mod_authors,
                custom_sources_attributes: custom_sources,
                required_mods_attributes: required_mods
            }
        };
        objectUtils.deleteEmptyProperties(modData, 1);

        // submit mod
        return backend.update('/mods/' + mod.id, modData);
    };

    this.submitImage = function(modId, image) {
        return backend.postFile('/mods/' + modId + '/image', 'image', image);
    };
});