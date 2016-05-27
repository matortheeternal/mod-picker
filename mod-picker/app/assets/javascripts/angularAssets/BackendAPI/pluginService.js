app.service('pluginService', function (backend, $q) {
    this.retrievePlugin = function (pluginId) {
        return backend.retrieve('/plugins/' + pluginId);
    };

    this.searchPlugins = function (filename) {
        var plugins = $q.defer();

        var postData =  {
            filters: {
                search: filename
            }
        };

        backend.post('/plugins/search', postData).then(function (data) {
            plugins.resolve(data);
        });

        return plugins.promise;
    };
});
