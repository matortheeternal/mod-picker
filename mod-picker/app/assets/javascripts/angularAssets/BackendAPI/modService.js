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

    this.retrieveModContributions = function(modId, route, options, pageInformation) {
        var action = $q.defer();
        backend.post('/mods/' + modId + '/' + route, options).then(function (data) {
            var contributions = data[route];
            contributionService.associateHelpfulMarks(contributions, data.helpful_marks);
            userTitleService.associateTitles(contributions);
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(contributions);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveModReviews = function(modId, options, pageInformation) {
        var reviews = $q.defer();
        this.retrieveModContributions(modId, 'reviews', options, pageInformation).then(function(data) {
            reviewSectionService.associateReviewSections(data);
            reviews.resolve(data);
        }, function(response) {
            reviews.reject(response);
        });
        return reviews.promise;
    };

    this.retrieveModAnalysis = function(modId) {
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
