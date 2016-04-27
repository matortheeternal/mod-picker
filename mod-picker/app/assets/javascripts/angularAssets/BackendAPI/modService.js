app.service('modService', function (backend, $q) {
    this.retrieveMod = function (modId) {
        return backend.retrieve('/mods/' + modId);
    };

    this.submitMod = function (mod) {
        var update = $q.defer();
        backend.update('/mods/' + mod.id, {mod: mod}).then(function (data) {
            update.resolve(data);
        });
        return update.promise;
    };

    var pages = {
        current: 1
    };

    this.retrieveMods = function (filters, sort, newPage) {
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

    this.retrieveCompatibilityNotes = function (modVersionId) {
        var compatibilityNotes = $q.defer();
        backend.retrieve('/mod_versions/' + modVersionId + '/compatibility_notes').then(function (data) {
            compatibilityNotes.resolve(data);
        });
        return compatibilityNotes.promise;
    };

    this.retrieveInstallOrderNotes = function (modVersionId) {
        var installOrderNotes = $q.defer();
        backend.retrieve('/mod_versions/' + modVersionId + '/install_order_notes').then(function (data) {
            installOrderNotes.resolve(data);
        });
        return installOrderNotes.promise;
    };

    this.retrieveLoadOrderNotes = function (modVersionId) {
        var loadOrderNotes = $q.defer();
        backend.retrieve('/mod_versions/' + modVersionId + '/load_order_notes').then(function (data) {
            loadOrderNotes.resolve(data);
        });
        return loadOrderNotes.promise;
    };
});
