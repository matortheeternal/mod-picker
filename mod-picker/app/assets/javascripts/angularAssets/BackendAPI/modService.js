app.service('modService', function(backend, $q, helpfulMarkService, userTitleService, categoryService, recordGroupService, assetUtils, errorsFactory) {
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

    this.retrieveAssociation = function(modId, name, options) {
        var action = $q.defer();
        backend.retrieve('/mods/' + modId + '/' + name, options).then(function (data) {
            var notes = data.reviews || data.compatibility_notes || data.load_order_notes || data.install_order_notes;
            helpfulMarkService.associateHelpfulMarks(notes, data.helpful_marks);
            userTitleService.associateTitles(notes);
            action.resolve(notes);
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

            //combine dummy_masters array with masters array and sort the masters array
            analysis.plugins.forEach(function(plugin) {
                plugin.masters = plugin.masters.concat(plugin.dummy_masters);
                plugin.masters.sort(function(first_master, second_master) {
                    return first_master.index - second_master.index;
                });

                //associate overrides with their master file
                plugin.masters.forEach(function(master) {
                    master.overrides = [];
                    plugin.overrides.forEach(function(override) {
                        if (override.fid >= master.index * 0x01000000) {
                            master.overrides.push(override);
                        }
                    });
                });

                //sort plugin errors
                plugin.sortedErrors = errorsFactory.errorTypes();
                plugin.plugin_errors.forEach(function(error) {
                    plugin.sortedErrors[error.group].errors.push(error);
                });
            });

            output.resolve(analysis);
        });
        return output.promise;
    };
});
