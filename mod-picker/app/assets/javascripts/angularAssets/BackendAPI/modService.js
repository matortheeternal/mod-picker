app.service('modService', function (backend) {
    this.retrieveMod = function (modId) {
        return backend.retrieve('/mods/' + modId);
    };

    this.retrieveMods = function () {
        return backend.retrieve('/mods');
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