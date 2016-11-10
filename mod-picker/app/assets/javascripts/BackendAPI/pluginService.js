app.service('pluginService', function(backend, $q, $timeout, recordGroupService, errorsFactory, objectUtils, pageUtils) {
    var service = this;

    this.retrievePlugins = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/plugins', options).then(function(data) {
            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrievePlugin = function(pluginId) {
        var output = $q.defer();
        backend.retrieve('/plugins/' + pluginId).then(function(plugin) {
            // prepare plugin data for display
            var plugins = [plugin];
            recordGroupService.associateGroups(plugins);
            service.combineAndSortMasters(plugins);
            service.associateOverrides(plugins);
            service.sortErrors(plugins);
            output.resolve(plugin);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.searchPlugins = function(filename, modIds) {
        var plugins = $q.defer();
        var postData =  {
            filters: {
                search: filename
            }
        };
        if (angular.isDefined(modIds)) {
            postData.filters.mods = modIds;
        }
        backend.post('/plugins/search', postData).then(function(data) {
            plugins.resolve(data);
        });
        return plugins.promise;
    };

    this.searchModListPluginStore = function($scope) {
        return function(str) {
            var action = $q.defer();
            var matchingPlugins = $scope.plugins_store.filter(function(plugin) {
                return plugin.filename.toLowerCase().includes(str);
            });
            action.resolve(matchingPlugins);
            return action.promise;
        };
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

    this.getLoadOrderPlugin = function(loadOrder, plugin_id) {
        return loadOrder.find(function(item) {
            return item.plugin_id == plugin_id;
        });
    };

    // get the load order ordinal of a plugin
    this.getLoadOrder = function(loadOrder, plugin_id) {
        var found = service.getLoadOrderPlugin(loadOrder, plugin_id);
        if (found) {
            return found.index;
        } else {
            return -1;
        }
    };

    this.buildLoadOrderOverrides = function(plugins, loadOrder) {
        var load_order_overrides = [];

        // build array of load order overrides
        plugins.forEach(function(plugin) {
            for (var group in plugin.formatted_overrides) {
                if (!plugin.formatted_overrides.hasOwnProperty(group)) continue;
                var formIDs = plugin.formatted_overrides[group];
                formIDs.forEach(function(formID) {
                    var master_index = formID >>> 24;
                    var master = plugin.masters[master_index];
                    var load_ordinal = service.getLoadOrder(loadOrder, master.master_plugin_id);
                    if (load_ordinal == -1) return;
                    var fid = formID % 0x01000000 + load_ordinal * 0x01000000;
                    load_order_overrides.push({
                        sig: group,
                        fid: fid,
                        plugin_ids: [plugin.id]
                    });
                });
            }
        });

        // return result
        return load_order_overrides;
    };

    this.compactLoadOrderOverrides = function(loadOrderOverrides) {
        // sort array
        loadOrderOverrides.sort(function(first_override, second_override) {
            return first_override.fid - second_override.fid;
        });

        // compact array
        var prevOverride = {
            fid: -1
        };
        for (var i = loadOrderOverrides.length - 1; i >= 0; i--) {
            var override = loadOrderOverrides[i];
            if (override.fid == prevOverride.fid) {
                prevOverride.plugin_ids.push(override.plugin_ids[0]);
                loadOrderOverrides.splice(i, 1);
            } else {
                prevOverride = override;
            }
        }
    };

    //associate overrides with their master file
    this.associateOverrides = function(plugins) {
        // loop through plugins
        plugins.forEach(function(plugin) {
            plugin.masters.forEach(function(master) {
                master.overrides = [];
                master.max_overrides = 1000;
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
            plugin.has_overrides = !objectUtils.isEmptyObject(plugin.formatted_overrides);
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
