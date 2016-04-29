app.service('pluginService', function (backend, $q) {
    this.retrievePlugin = function (pluginId) {
        return backend.retrieve('/plugins/' + pluginId);
    };
});
