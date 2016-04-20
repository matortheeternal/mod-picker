app.service('modService', function (backend, $q) {
    this.retrieveMod = function (modId) {
        return backend.retrieve('/mods/' + modId);
    };

    this.retrieveMods = function (filters, sort) {
        var mods = $q.defer();
        var postData =  {
            filters: filters,
            sort: sort
        };
        backend.post('/mods', postData).then(function (data) {
                mods.resolve(data);
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
