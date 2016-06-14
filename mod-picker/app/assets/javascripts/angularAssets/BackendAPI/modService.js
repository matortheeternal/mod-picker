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
        var mods = $q.defer();
        var postData =  {
            filters: {
                search: name
            }
        };
        backend.post('/mods/search', postData).then(function (data) {
            mods.resolve(data);
        });
        return mods.promise;
    };

    this.starMod = function(modId, starred) {
        var star = $q.defer();
        if (starred) {
            backend.delete('/mods/' + modId + '/star').then(function (data) {
                star.resolve(data);
            });
        } else {
            backend.post('/mods/' + modId + '/star', {}).then(function (data) {
                star.resolve(data);
            });
        }
        return star.promise;
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

    this.retrieveAnalysis = function(modId, gameId) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/' + 'analysis').then(function (analysis) {
            // turn assets into an array of string
            // create nestedAssets tree
            analysis.assets = analysis.assets.map(function(asset) {
                return asset.filepath;
            });
            analysis.nestedAssets = assetUtils.convertDataStringToNestedObject(analysis.assets);

            // associate groups with plugins
            recordGroupService.associateGroups(analysis.plugins);

            // combine dummy_masters array with masters array and sorts the masters array
            // and associate overrides with their master file
            pluginService.combineAndSortMasters(analysis.plugins);
            pluginService.associateOverrides(analysis.plugins);
            pluginService.sortErrors(analysis.plugins);

            output.resolve(analysis);
        });
        return output.promise;
    };
});
