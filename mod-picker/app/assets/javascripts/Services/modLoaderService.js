app.service('modLoaderService', function(gameService, sitesFactory, assetUtils) {
    var service = this;
    
    this.loadSource = function(mod, infoLabel, sourceLabel, gameName) {
        infoLabel = infoLabel + '_infos';
        if (mod[infoLabel]) {
            var sourceId = mod[infoLabel].id;
            mod.sources.push({
                label: sourceLabel,
                url: sitesFactory.getModUrl("Nexus Mods", sourceId, gameName),
                valid: true,
                old: true,
                scraped: true
            });
        }
    };

    this.loadSources = function(mod) {
        gameService.getGameById(window._current_game_id).then(function(game) {
            mod.sources = [];
            service.loadSource(mod, "nexus", "Nexus Mods", game.nexus_name);
            service.loadSource(mod, "lover", "Lover's Lab");
            service.loadSource(mod, "workshop", "Steam Workshop");
        });
    };

    this.loadCustomSources = function(mod) {
        mod.custom_sources.forEach(function(source) {
            source.valid = true;
        });
    };

    this.loadDates = function(mod) {
        mod.released = new Date(Date.parse(mod.released));
        if (mod.updated) {
            mod.updated = new Date(Date.parse(mod.updated));
        }
    };

    this.loadRequirements = function(mod) {
        mod.requirements = [];
        mod.required_mods.forEach(function(requirement) {
            mod.requirements.push({
                id: requirement.id,
                required_id: requirement.required_mod.id,
                name: requirement.required_mod.name
            })
        });
    };

    this.loadCategories = function(mod) {
        mod.categories = [];
        if (mod.primary_category_id) {
            mod.categories.push(mod.primary_category_id);
        }
        if (mod.secondary_category_id) {
            mod.categories.push(mod.secondary_category_id);
        }
    };

    this.loadAssets = function(mod) {
        mod.mod_options.forEach(function(option) {
            if (!option.asset_file_paths || !option.asset_file_paths.length) return;
            option.nestedAssets = assetUtils.getNestedAssets(option.asset_file_paths);
        });
    };

    this.loadMod = function(mod) {
        service.loadSources(mod);
        service.loadCustomSources(mod);
        service.loadDates(mod);
        service.loadRequirements(mod);
        service.loadCategories(mod);
        service.loadAssets(mod);
        mod.newTags = [];
    }
});