app.service('modService', function(backend, $q) {
    this.retrieveMod = function(modId) {
        return backend.retrieve('/mods/' + modId);
    };

    this.retrieveMods = function(options) {
        var action = $q.defer();
        backend.post('/mods/index', options).then(function (data) {
            action.resolve(data);
        });
        return action.promise;
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

    this.retrieveAssociation = function(modId, name, options) {
        var action = $q.defer();
        if (options) {
            backend.post('/mods/' + modId + '/' + name, options).then(function (data) {
                action.resolve(data);
            });
        } else {
            backend.retrieve('/mods/' + modId + '/' + name).then(function (data) {
                action.resolve(data);
            });
        }
        return action.promise;
    };
});
