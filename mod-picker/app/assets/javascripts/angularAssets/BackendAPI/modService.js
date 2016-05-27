app.service('modService', function(backend, $q, helpfulMarkService, userTitleService, categoryService, reviewSectionService, recordGroupService, assetUtils) {
    this.retrieveMod = function(modId) {
      output = $q.defer();
      backend.retrieve('/mods/' + modId).then(function(modObject) {
        //get category objects with ids
        categoryService.getCategoryById(modObject.mod.primary_category_id).then(function(primaryCategory) {
          //set primary category on mod
          modObject.mod.primary_category = primaryCategory;

          categoryService.getCategoryById(modObject.mod.secondary_category_id).then(function(secondaryCategory) {
            //set secondary category on mod
            modObject.mod.secondary_category = secondaryCategory;

            //resolve output after both categories are set
            output.resolve(modObject);
          });
        });
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

    this.retrieveReviews = function(modId, options) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/reviews', options).then(function (data) {
            helpfulMarkService.associateHelpfulMarks(data.reviews, data.helpful_marks);
            userTitleService.associateTitles(data.reviews);
            reviewSectionService.associateReviewSections(data.reviews);
            output.resolve(data.reviews);
        });
        return output.promise;
    };

    this.retrieveCompatibilityNotes = function(modId, options) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/compatibility_notes', options).then(function (data) {
            helpfulMarkService.associateHelpfulMarks(data.compatibility_notes, data.helpful_marks);
            userTitleService.associateTitles(data.compatibility_notes);
            output.resolve(data.compatibility_notes);
        });
        return output.promise;
    };

    this.retrieveInstallOrderNotes = function(modId, options) {
        var installOrderNotes = $q.defer();
        backend.retrieve('/mods/' + modId + '/install_order_notes', options).then(function (data) {
            helpfulMarkService.associateHelpfulMarks(data.install_order_notes, data.helpful_marks);
            userTitleService.associateTitles(data.install_order_notes);
            installOrderNotes.resolve(data.install_order_notes);
        });
        return installOrderNotes.promise;
    };

    this.retrieveLoadOrderNotes = function(modId, options) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/load_order_notes', options).then(function (data) {
            helpfulMarkService.associateHelpfulMarks(data.load_order_notes, data.helpful_marks);
            userTitleService.associateTitles(data.load_order_notes);
            output.resolve(data.load_order_notes);
        });
        return output.promise;
    };

    this.retrieveAnalysis = function(modId, gameId, options) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/analysis', options).then(function (analysis) {
            // turn assets into an array of string
            analysis.assets = analysis.assets.map(function(asset) {
                return asset.filepath;
            });
            // create nestedAssets tree
            analysis.nestedAssets = assetUtils.convertDataStringToNestedObject(analysis.assets);
            //associate groups with plugins
            recordGroupService.associateGroups(analysis.plugins, gameId);

            output.resolve(data);
        });
        return output.promise;
    };
});
