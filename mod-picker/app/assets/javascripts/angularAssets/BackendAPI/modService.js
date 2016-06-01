app.service('modService', function(backend, $q) {
    this.retrieveMod = function(modId) {
        return backend.retrieve('/mods/' + modId);
    };

    var pages = {
        current: 1
    };

    this.retrieveMods = function(filters, sort, newPage) {
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
        backend.retrieve('/mods/' + modId + '/' + name, options).then(function (data) {
            action.resolve(data);
        });
        return action.promise;
    };
});
