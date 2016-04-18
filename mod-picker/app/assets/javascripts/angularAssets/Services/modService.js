app.service('modService', function (backend, $q) {
    this.retrieveMod = function (modId) {
        return backend.retrieve('/mods/' + modId);
    };

    this.retrieveMods = function (filters) {
        var mods = $q.defer();
        backend.post('/mods', filters).then(function (data) {
                mods.resolve(data);
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
