app.service('modValidationService', function() {
    var service = this;

    this.sourcesValid = function(mod) {
        var sourcesValid = true;
        var oldSources = false;
        mod.sources.forEach(function(source) {
            sourcesValid = sourcesValid && source.valid;
            oldSources = oldSources || source.old;
        });

        // custom source validation
        var customSources = mod.custom_sources;
        if (customSources.length) {
            customSources.forEach(function(source) {
                sourcesValid = sourcesValid && source.valid;
            });
        }
        else {
            // if we don't have any custom sources we should verify we have
            // the scraped data for at least one official source
            sourcesValid = sourcesValid && (!!mod.nexus || !!mod.workshop || !!mod.lab || oldSources);
        }

        return sourcesValid;
    };

    this.metadataValid = function(mod) {
        return !!mod.name && !!mod.authors && !!mod.released;
    };

    this.licenseValid = function(mod_license) {
        if (mod_license.custom) {
            return mod_license.text_body && mod_license.text_body.length > 4;
        } else {
            return true;
        }
    };

    this.licensesValid = function(mod) {
        var licensesValid = true;
        var targets = {
            materials: 0,
            code: 0,
            assets: 0
        };
        mod.mod_licenses.forEach(function(mod_license) {
            licensesValid = licensesValid && service.licenseValid(mod_license);
            targets[mod_license.target]++;
        });
        var noDuplicateTargets = targets.materials < 2 && targets.code < 2 && targets.assets < 2;
        var validMaterialsTarget = (targets.materials + targets.code < 2) && (targets.materials + targets.assets < 2);
        return licensesValid && noDuplicateTargets && validMaterialsTarget;
    };

    this.sanitizeSet = function(set) {
        set.forEach(function(item) {
            delete item.error;
        });
    };

    this.setValid = function(set, key) {
        var setValid = true;
        var setIds = [];
        set.forEach(function(item) {
            var itemId = item[key];
            setValid = setValid && !!itemId;
            if (!itemId || item._destroy) return;
            var idPresent = setIds.indexOf(itemId) > -1;
            if (idPresent) {
                item.error = true;
                setValid = false;
            } else {
                item.error = false;
                setIds.push(itemId);
            }
        });

        return setValid;
    };

    this.authorsValid = function(mod_authors) {
        return service.setValid(mod_authors, 'user_id');
    };

    this.requirementsValid = function(requirements) {
        return service.setValid(requirements, 'required_id');
    };

    this.configsValid = function(config_files) {
        var configsValid = true;
        config_files.forEach(function(configFile) {
            configsValid = configsValid && !!configFile.filename.length &&
                !!configFile.install_path.length && !!configFile.text_body.length;
        });
        return configsValid;
    };

    this.categoriesValid = function(mod) {
        return !!mod.categories && mod.categories.length <= 2 && (mod.is_official || !!mod.categories.length);
    };
});