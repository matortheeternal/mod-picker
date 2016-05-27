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

    this.associateRecordGroups = function(plugins, recordGroups) {
        // if we don't have recordGroups yet, try again in 100ms
        var service = this;
        if (!recordGroups) {
            $timeout(function() {
                service.associateRecordGroups(plugins, recordGroups);
            }, 100);
            return;
        }

        // loop through plugins to associate record groups
        plugins.forEach(function(plugin) {
            if (plugin.plugin_record_groups) {
                plugin.plugin_record_groups.forEach(function(group) {
                    var record_group = recordGroupService.getGroupFromSignature(recordGroups, group.sig);
                    group.name = record_group.name;
                    group.child_group = record_group.child_group;
                });
            }
        });
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
                plugin.overrides.forEach(function(override) {
                    if (override.fid >= master.index * 0x01000000) {
                        master.overrides.push(override);
                    }
                });
            });
        });
    };

    //sort plugin errors
    this.sortErrors = function(plugin) {
        var sortedErrors = errorsFactory.errorTypes();
        // return if we don't have a plugin to sort errors for
        if (!plugin) {
            return;
        }

        // loop through plugin's errors, sorting them
        plugin.plugin_errors.forEach(function(error) {
            sortedErrors[error.group].errors.push(error);
        });

        // return the sorted errors
        return sortedErrors;
    };
});
