app.service('modListService', function (backend, $q) {
    this.retrieveModList = function(modListId) {
        return backend.retrieve('/mod_lists/' + modListId);
    };

    this.updateModList = function(modlist) {
        return backend.update('/mod_lists/' + modlist.id, { mod_list: modlist });
    };

    this.starModList = function(modListId, starred) {
        if (starred) {
            return backend.delete('/mod_lists/' + modListId + '/star');
        } else {
            return backend.post('/mod_lists/' + modListId + '/star', {});
        }
    };
});
