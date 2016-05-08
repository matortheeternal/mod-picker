app.service('modListService', function (backend, $q) {
    this.retrieveModList = function (modListId) {
        return backend.retrieve('/mod_lists/' + modListId);
    };

    // copypasted from the modService
    // this.retrieveMods = function (filters, sort, newPage) {
    //     var mods = $q.defer();

    //     if(newPage && newPage > pages.max) {
    //         mods.reject();
    //         return mods.promise;
    //     }

    //     pages.current = newPage || pages.current;

    //     var postData =  {
    //         filters: filters,
    //         sort: sort,
    //         page: pages.current
    //     };

    //     backend.post('/mods', postData).then(function (data) {
    //         pages.max = Math.ceil(data.max_entries / data.entries_per_page);
    //         mods.resolve({
    //             mods: data.mods,
    //             pageInformation: pages
    //         });
    //     });

    //     return mods.promise;
    // };

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
