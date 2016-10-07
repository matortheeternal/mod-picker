app.service('modValidationService', function() {
    var service = this;

    this.sourcesValid = function($scope) {
        var sourcesValid = true;
        var oldSources = false;
        $scope.sources.forEach(function(source) {
            sourcesValid = sourcesValid && source.valid;
            oldSources = oldSources || source.old;
        });

        // custom source validation
        if ($scope.customSources.length) {
            $scope.customSources.forEach(function(source) {
                sourcesValid = sourcesValid && source.valid;
            });
            // if we are only submitting custom sources, we need to verify
            // we have all general info
            if (!$scope.sources.length) {
                sourcesValid = sourcesValid && $scope.mod.name && $scope.mod.authors &&
                    $scope.mod.released;
            }
        }
        else {
            // if we don't have any custom sources we should verify we have
            // the scraped data for at least one official source
            sourcesValid = sourcesValid && ($scope.nexus || $scope.workshop || $scope.lab || oldSources);
        }

        return sourcesValid;
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
            setValid = setValid && itemId;
            if (!itemId) return;
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
            configsValid = configsValid && configFile.filename.length &&
                configFile.install_path.length && configFile.text_body.length;
        });
        return configsValid;
    };

    this.categoriesValid = function(mod) {
        return mod.categories.length <= 2 && mod.is_official || mod.categories.length;
    };
});