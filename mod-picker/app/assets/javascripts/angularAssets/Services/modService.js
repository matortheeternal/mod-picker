app.service('modService', function (backend, $q) {
    this.retrieveMod = function (modId) {
        var mod = $q.defer();
        backend.retrieve('/mods/' + modId).then(function (data) {
            //TODO: remove mocked delay
            setTimeout(function () {
                mod.resolve(data);
            }, 1000);
        });
        return mod.promise;
    };

    this.retrieveMods = function (filters) {
        var mods = $q.defer();
        backend.post('/mods', filters).then(function (data) {
            //TODO: remove mocked delay
            setTimeout(function () {
                mods.resolve(data);
            }, 1000);
        });
        return mods.promise;
    };

    this.retrieveCompatibilityNotes = function (modId, versionId) {
        return backend.retrieve('/compatibility_notes', {
            params: {
                mod: modId,
                mv: versionId
            }
        });
    };
});
