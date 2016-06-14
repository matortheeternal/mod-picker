app.service('modService', function(backend, $q, userTitleService, categoryService, recordGroupService, assetUtils, errorsFactory, pluginService, reviewSectionService, contributionService, pageUtils) {
    this.retrieveMod = function(modId) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId).then(function(data) {
            categoryService.resolveModCategories(data.mod);
            output.resolve(data);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.retrieveMods = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/mods/index', options).then(function (data) {
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.searchMods = function(name) {
        var postData =  {
            filters: {
                search: name
            }
        };
        return backend.post('/mods/search', postData);
    };

    this.starMod = function(modId, starred) {
        if (starred) {
            return backend.delete('/mods/' + modId + '/star');
        } else {
            return backend.post('/mods/' + modId + '/star', {});
        }
    };

    this.retrieveCorrections = function(modId) {
        var action = $q.defer();
        backend.retrieve('/mods/' + modId + '/corrections').then(function (data) {
            contributionService.associateAgreementMarks(data.corrections, data.agreement_marks);
            userTitleService.associateTitles(data.corrections);
            action.resolve(data.corrections);
        });
        return action.promise;
    };

    this.retrieveContributions = function(modId, name, options, pageInformation) {
        var action = $q.defer();
        if (options) {
            backend.post('/mods/' + modId + '/' + name, options).then(function (data) {
                var contributions = data[name];
                contributionService.associateHelpfulMarks(contributions, data.helpful_marks);
                userTitleService.associateTitles(contributions);
                pageUtils.getPageInformation(data, pageInformation, options.page);
                action.resolve(contributions);
            });
        } else {
            backend.retrieve('/mods/' + modId + '/' + name).then(function (data) {
                var contributions = data[name];
                contributionService.associateHelpfulMarks(contributions, data.helpful_marks);
                userTitleService.associateTitles(contributions);
                action.resolve(contributions);
            });
        }
        return action.promise;
    };

    this.retrieveReviews = function(modId, options, pageInformation) {
        var reviews = $q.defer();
        this.retrieveContributions(modId, 'reviews', options, pageInformation).then(function(data) {
            reviewSectionService.associateReviewSections(data);
            reviews.resolve(data);
        });
        return reviews.promise;
    };

    this.retrieveAnalysis = function(modId) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/' + 'analysis').then(function (analysis) {
            // turn assets into an array of string
            analysis.assets = analysis.assets.map(function(asset) {
                return asset.filepath;
            });
            // create nestedAssets tree
            analysis.nestedAssets = assetUtils.convertDataStringToNestedObject(analysis.assets);

            // prepare plugin data for display
            recordGroupService.associateGroups(analysis.plugins);
            pluginService.combineAndSortMasters(analysis.plugins);
            pluginService.associateOverrides(analysis.plugins);
            pluginService.sortErrors(analysis.plugins);

            output.resolve(analysis);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };
});
