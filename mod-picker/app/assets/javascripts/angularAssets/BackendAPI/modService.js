app.service('modService', function(backend, $q, helpfulMarkService, userTitleService, categoryService, recordGroupService, assetUtils, errorsFactory, pluginService) {
    this.retrieveMod = function(modId) {
        output = $q.defer();
        backend.retrieve('/mods/' + modId).then(function(modData) {
            //get category objects with ids
            if(modData.mod.primary_category_id){
                categoryService.getCategoryById(modData.mod.primary_category_id).then(function(primaryCategory) {
                    //set primary category on mod
                    modData.mod.primary_category = primaryCategory;

                    if(modData.mod.secondary_category_id) {
                        categoryService.getCategoryById(modData.mod.secondary_category_id).then(function(secondaryCategory) {
                            //set secondary category on mod
                            modData.mod.secondary_category = secondaryCategory;

                            //resolve output after both categories are set
                            output.resolve(modData);
                        });
                    } else {
                        output.resolve(modData);
                    }
                });
            } else {
                output.resolve(modData);
            }
        });
        return output.promise;
    };

    var pages = {
        current: 1
    };

    this.retrieveMods = function(filters, sort, newPage) {
        var mods = $q.defer();

        if(newPage && newPage > pages.max) {
            mods.reject();
            return mods.promise;
        }
        pages.current = newPage || pages.current;

        var postData =  {
            filters: filters,
            sort: sort,
            page: pages.current
        };
        backend.post('/mods', postData).then(function (data) {
            pages.max = Math.ceil(data.max_entries / data.entries_per_page);
            mods.resolve({
                mods: data.mods,
                pageInformation: pages
            });
        });
        return mods.promise;
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

    this.retrieveContributions = function(modId, name, options) {
        var action = $q.defer();
        backend.retrieve('/mods/' + modId + '/' + name, options).then(function (data) {
            var contributions = data[name];
            helpfulMarkService.associateHelpfulMarks(contributions, data.helpful_marks);
            userTitleService.associateTitles(contributions);
            action.resolve(contributions);
        });
        return action.promise;
    };

    this.retrieveAnalysis = function(modId, gameId) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/' + 'analysis').then(function (analysis) {
            // turn assets into an array of string
            analysis.assets = analysis.assets.map(function(asset) {
                return asset.filepath;
            });
            // create nestedAssets tree
            analysis.nestedAssets = assetUtils.convertDataStringToNestedObject(analysis.assets);

            //associate groups with plugins
            recordGroupService.associateGroups(analysis.plugins, gameId);

            //combine dummy_masters array with masters array and sorts the masters array
            pluginService.combineAndSortMasters(analysis.plugins);

            //associate overrides with their master file
            pluginService.associateOverrides(analysis.plugins);

            pluginService.sortErrors(analysis.plugins);

            output.resolve(analysis);
        });
        return output.promise;
    };
});
