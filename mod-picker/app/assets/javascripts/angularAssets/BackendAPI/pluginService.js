app.service('pluginService', function (backend, $q, $timeout, recordGroupService, errorsFactory) {
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

    //combine dummy_masters array with masters array and sorts the masters array
    this.combineAndSortMasters = function(plugins) {
        // loop through plugins
        plugins.forEach(function(plugin) {
            plugin.masters = plugin.masters.concat(plugin.dummy_masters);
            plugin.masters.sort(function(first_master, second_master) {
                return first_master.index - second_master.index;
            });
        });
    };

    //associate overrides with their master file
    this.associateOverrides = function(plugins) {
        // loop through plugins
        plugins.forEach(function(plugin) {
            plugin.masters.forEach(function(master) {
                master.overrides = [];
                for (var group in plugin.formatted_overrides) {
                    if (!plugin.formatted_overrides.hasOwnProperty(group)) continue;
                    var formIDs = plugin.formatted_overrides[group];
                    formIDs.forEach(function(formID) {
                        if (formID >>> 24 != master.index) return;
                        master.overrides.push({
                            sig: group,
                            fid: formID
                        });
                    });
                }
            });
        });
    };

    //sort plugin errors
    this.sortErrors = function(plugins) {
        plugins.forEach(function(plugin) {
            // return if we don't have errors to sort
            if (!plugin.plugin_errors.length) {
                return;
            }

            var sortedErrors = errorsFactory.errorTypes();
            // loop through plugin's errors, sorting them
            plugin.plugin_errors.forEach(function(error) {
                sortedErrors[error.group].errors.push(error);
            });

            // return the sorted errors
            plugin.plugin_errors = sortedErrors;
        });
    };
});
