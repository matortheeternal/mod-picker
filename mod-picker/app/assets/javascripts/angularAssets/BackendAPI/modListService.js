app.service('modListService', function (backend, $q) {
    this.retrieveModList = function(modListId) {
        return backend.retrieve('/mod_lists/' + modListId);
    };

    this.updateModList = function(modlist) {
        return backend.update('/mod_lists/' + modlist.id, { mod_list: modlist });
    };

    this.starModList = function(modId, starred) {
        var star = $q.defer();
        if (starred) {
            backend.delete('/mod_lists/' + modListId + '/star').then(function (data) {
                star.resolve(data);
            });
        } else {
            backend.post('/mod_lists/' + modListId + '/star', {}).then(function (data) {
                star.resolve(data);
            });
        }
        return star.promise;
    };
});
