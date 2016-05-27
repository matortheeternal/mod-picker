app.service('modService', function(backend, $q) {
    this.retrieveMod = function(modId) {
        return backend.retrieve('/mods/' + modId);
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

    this.retrieveCorrections = function(modId, options) {
        var corrections = $q.defer();
        backend.retrieve('/mods/' + modId + '/corrections', options).then(function (data) {
            corrections.resolve(data);
        });
        return corrections.promise;
    };

    this.retrieveReviews = function(modId, options) {
        var reviews = $q.defer();
        backend.retrieve('/mods/' + modId + '/reviews', options).then(function (data) {
            reviews.resolve(data);
        });
        return reviews.promise;
    };

    this.retrieveCompatibilityNotes = function(modId, options) {
        var compatibilityNotes = $q.defer();
        backend.retrieve('/mods/' + modId + '/compatibility_notes', options).then(function (data) {
            compatibilityNotes.resolve(data);
        });
        return compatibilityNotes.promise;
    };

    this.retrieveInstallOrderNotes = function(modId, options) {
        var installOrderNotes = $q.defer();
        backend.retrieve('/mods/' + modId + '/install_order_notes', options).then(function (data) {
            installOrderNotes.resolve(data);
        });
        return installOrderNotes.promise;
    };

    this.retrieveLoadOrderNotes = function(modId, options) {
        var loadOrderNotes = $q.defer();
        backend.retrieve('/mods/' + modId + '/load_order_notes', options).then(function (data) {
            loadOrderNotes.resolve(data);
        });
        return loadOrderNotes.promise;
    };

    this.retrieveAnalysis = function(modId, options) {
        var analysis = $q.defer();
        backend.retrieve('/mods/' + modId + '/analysis', options).then(function (data) {
            analysis.resolve(data);
        });
        return analysis.promise;
    };
});
