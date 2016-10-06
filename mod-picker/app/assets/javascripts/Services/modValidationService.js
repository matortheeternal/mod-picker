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
            // if we are only submitting custom soruces, we need to verify
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

    this.authorsValid = function(mod_authors) {
        var authorsValid = true;
        var authorIds = [];
        mod_authors.forEach(function(modAuthor) {
            var userId = modAuthor.user_id;
            authorsValid = authorsValid && userId;
            if (!userId) return;
            var idPresent = authorIds.indexOf(userId) > -1;
            if (idPresent) {
                modAuthor.error = true;
                authorsValid = false;
            } else {
                modAuthor.error = false;
                authorIds.push(userId);
            }
        });

        return authorsValid;
    };

    this.requirementsValid = function(requirements) {
        var requirementsValid = true;
        requirements.forEach(function(requirement) {
            requirementsValid = requirementsValid && requirement.required_id;
        });
        return requirementsValid;
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