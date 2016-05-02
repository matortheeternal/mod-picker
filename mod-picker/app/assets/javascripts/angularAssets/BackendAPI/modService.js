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

    this.retrieveCompatibilityNotes = function (modId) {
        var compatibilityNotes = $q.defer();
        backend.retrieve('/mods/' + modId + '/compatibility_notes').then(function (data) {
            compatibilityNotes.resolve(data);
        });
        return compatibilityNotes.promise;
    };

    this.retrieveInstallOrderNotes = function (modId) {
        var installOrderNotes = $q.defer();
        backend.retrieve('/mods/' + modId + '/install_order_notes').then(function (data) {
            installOrderNotes.resolve(data);
        });
        return installOrderNotes.promise;
    };

    this.retrieveLoadOrderNotes = function (modId) {
        var loadOrderNotes = $q.defer();
        backend.retrieve('/mods/' + modId + '/load_order_notes').then(function (data) {
            loadOrderNotes.resolve(data);
        });
        return loadOrderNotes.promise;
    };
});
