app.service('modService', function (backend, $q) {
    this.retrieveMod = function (modId) {
        var mod = $q.defer();
        backend.retrieve('/mods/' + modId).then(function (data) {
            setTimeout(function () {
                mod.resolve(data);
            }, 1000);
        });
        return mod.promise;
    };

    this.retrieveMods = function () {
        var mods = $q.defer();
        backend.retrieve('/mods').then(function (data) {
            setTimeout(function () {
                mods.resolve(data);
            }, 1000);
        });
        return mods.promise;
    };

    this.retrieveCompabilityNotes = function (modId, versionId) {
        return backend.retrieve('/compatibility_notes', {
            params: {
                mod: modId,
                mv: versionId
            }
        });
    };
});