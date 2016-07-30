app.controller('modListPluginsController', function($scope, modListService, columnsFactory, actionsFactory) {
    // initialize variables
    $scope.columns = columnsFactory.modListPluginColumns();
    $scope.columnGroups = columnsFactory.modListPluginColumnGroups();
    $scope.actions = actionsFactory.modListPluginActions();

    // functions
    $scope.buildPluginsModel = function() {
        $scope.model.plugins = [];
        $scope.mod_list.groups.forEach(function(group) {
            if (group.tab !== 'plugins') {
                return;
            }
            $scope.model.plugins.push(group);
            group.children = $scope.mod_list.plugins.filter(function(plugin) {
                return plugin.group_id == group.id;
            });
        });
        $scope.mod_list.plugins.forEach(function(plugin) {
            if (!plugin.group_id) {
                var insertIndex = $scope.model.plugins.findIndex(function(item) {
                    return item.index > plugin.index;
                });
                if (insertIndex == -1) {
                    insertIndex = $scope.model.plugins.length;
                }
                $scope.model.plugins.splice(insertIndex, 0, plugin);
            }
        });
    };

    $scope.buildUnresolvedPluginCompatibility = function() {
        $scope.notes.unresolved_plugin_compatibility = [];
        $scope.notes.ignored_plugin_compatibility = [];
        $scope.notes.plugin_compatibility.forEach(function(note) {
            // skip destroyed or ignored notes
            if (note._destroy) {
                return;
            } else if (note.ignored) {
                $scope.notes.ignored_plugin_compatibility.push(note);
                return;
            }
            switch (note.status) {
                case 'compatibility plugin':
                    // unresolved if the compatibility plugin is not present and both mods are present
                    if (!$scope.findPlugin(note.compatibility_plugin_id, true) &&
                        $scope.findMod(note.mods[0].id, true) && $scope.findMod(note.mods[1].id, true)) {
                        note.resolved = false;
                        $scope.notes.unresolved_plugin_compatibility.push(note);
                    } else {
                        note.resolved = true;
                    }
                    break;
                case 'make custom patch':
                    // unresolved if the custom plugin is not present and both mods are present
                    if (!$scope.findCustomPlugin(note.id) &&
                        $scope.findMod(note.mods[0].id, true) && $scope.findMod(note.mods[1].id, true)) {
                        note.resolved = false;
                        $scope.notes.unresolved_plugin_compatibility.push(note);
                    } else {
                        note.resolved = true;
                    }
                    break;
            }
        });
    };

    $scope.buildUnresolvedLoadOrder = function() {
        $scope.notes.unresolved_load_order = [];
        $scope.notes.ignored_load_order = [];
        $scope.notes.load_order.forEach(function(note) {
            // skip destroyed or ignored notes
            if (note._destroy) {
                return;
            } else if (note.ignored) {
                $scope.notes.ignored_load_order.push(note);
                return;
            }
            var first_plugin = $scope.findPlugin(note.plugins[0].id, true);
            var second_plugin = $scope.findPlugin(note.plugins[1].id, true);
            // unresolved if the both mods are present and the first mod comes after the second mod
            if (first_plugin && second_plugin && first_plugin.index > second_plugin.index) {
                note.resolved = false;
                $scope.notes.unresolved_load_order.push(note);
            } else {
                note.resolved = true;
            }
        });
    };
    
    $scope.compactRequiredPlugins = function() {
        var requirements = $scope.required.plugins;
        var req, prev;
        for (var i = requirements.length; i >= 0; i--) {
            req = requirements[i];
            if (prev && req.master_plugin.id == prev.master_plugin.id) {
                prev.unshift(req.plugin);
                requirements.splice(i, 1);
            } else {
                req.plugins = [req.plugin];
                delete req.plugin;
            }
            prev = req;
        }
    };

    $scope.buildMissingPlugins = function() {
        $scope.required.missing_plugins = [];
        $scope.required.plugins.forEach(function(requirement) {
            // skip destroyed requirements
            if (requirement._destroy) {
                return;
            }
            var pluginPresent = $scope.findPlugin(requirement.master_plugin.id, true);
            // TODO: Check if one of the plugins in the plugins array is present
            if (!pluginPresent) {
                $scope.required.missing_plugins.push(requirement);
            }
        });
    };

    $scope.retrievePlugins = function() {
        $scope.retrieving.plugins = true;
        modListService.retrieveModListPlugins($scope.mod_list.id).then(function(data) {
            $scope.required.plugins = data.required_plugins;
            $scope.notes.plugin_compatibility = data.compatibility_notes;
            $scope.notes.load_order = data.load_order_notes;
            $scope.mod_list.plugins = data.plugins;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.plugins = angular.copy($scope.mod_list.plugins);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.buildPluginsModel();
            $scope.compactRequiredPlugins();
            $scope.buildMissingPlugins();
            $scope.buildUnresolvedPluginCompatibility();
            $scope.buildUnresolvedLoadOrder();
            $scope.retrieving.plugins = false;
        }, function(response) {
            $scope.errors.plugins = response;
        });
    };

    // retrieve plugins if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.plugins && !$scope.retrieving.plugins) {
        $scope.retrievePlugins();
    }
    
    // requirement handling
    $scope.getRequirerList = function(requirement) {
        return requirement.plugins.map(function(plugin) {
            return plugin.filename;
        }).join(', ');
    };
    
    $scope.removeRequirers = function(requirement) {
        // TODO
    };
    
    // plugin handling
    $scope.reAddPlugin = function(modListPlugin) {
        // if plugin is already present on the user's mod list but has been
        // removed, add it back
        if (modListPlugin._destroy) {
            delete modListPlugin._destroy;
            $scope.mod_list.plugins_count += 1;
            $scope.reAddPluginRequirements(modListPlugin.plugin.id);
            $scope.buildMissingPlugins();
            $scope.buildUnresolvedCompatibility();
            $scope.buildUnresolvedInstallOrder();
            $scope.updateTabs();
            $scope.$broadcast('updateItems');
            $scope.$emit('successMessage', 'Added plugin ' + modListPlugin.plugin.filename+ ' successfully.');
        }
        // else inform the user that the plugin is already on their mod list
        else {
            var params = {type: 'error', text: 'Failed to add plugin ' + modListPlugin.plugin.filename + ', the plugin has already been added to this mod list.'};
            $scope.$emit('customMessage', params);
        }
    };

    $scope.addNewPlugin = function(pluginId) {
        var mod_list_plugin = {
            mod_list_id: $scope.mod_list.id,
            plugin_id: pluginId,
            index: $scope.mod_list.plugins.length
        };

        modListService.newModListPlugin(mod_list_plugin).then(function(data) {
            // push mod onto view
            $scope.mod_list.plugins.push(data.mod_list_plugin);
            $scope.model.plugins.push(data.mod_list_plugin);
            $scope.mod_list.plugins_count += 1;
            $scope.updateTabs();

            // handle requirements
            Array.prototype.unite($scope.required.plugins, data.required_plugins);
            $scope.buildMissingPlugins();

            // handle notes
            Array.prototype.unite($scope.notes.compatibility, data.compatibility_notes);
            Array.prototype.unite($scope.notes.load_order, data.load_order);
            $scope.$emit('rebuildUnresolved');

            // success message
            $scope.$broadcast('updateItems');
            var filename = data.mod_list_plugin.plugin.filename;
            $scope.$emit('successMessage', 'Added plugin ' + filename + ' successfully.');
        }, function(response) {
            var params = {label: 'Error adding plugin', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addPlugin = function(pluginId) {
        // return if we don't have a mod to add
        if (!pluginId) {
            return;
        }

        // see if the plugin is already present on the user's plugin list
        var existingPlugin = $scope.findPlugin(pluginId);
        if (existingPlugin) {
            $scope.reAddPlugin(existingPlugin);
        } else {
            $scope.addNewPlugin(pluginId);
        }

        if ($scope.add.plugin.id) {
            $scope.add.plugin.id = null;
            $scope.add.plugin.name = "";
        }
    };

    $scope.removePlugin = function(modListPlugin) {
        modListPlugin._destroy = true;
        $scope.removeRequirements(modListPlugin.plugin.id);
        $scope.removeNotes(modListPlugin.plugin.id);
        $scope.buildMissingPlugins();
        $scope.buildUnresolvedPluginCompatibility();
        $scope.buildUnresolvedLoadOrder();
        $scope.mod_list.plugins_count -= 1;
        $scope.updateTabs();
        $scope.$broadcast('updateItems');
    };

    $scope.$on('removeItem', function(event, modListPlugin) {
        $scope.removePlugin(modListPlugin);
    });

    $scope.$on('resolveCompatibilityNote', function(event, options) {
        switch(options.action) {
            case "add plugin":
                $scope.addPlugin(options.note.compatibility_plugin.id);
                break;
            case "add custom plugin":
                $scope.addCustomPlugin(options.note.id);
                break;
            case "ignore":
                options.note.ignored = !options.note.ignored;
                // TODO: Update $scope.plugin_list.ignored_notes
                $scope.buildUnresolvedPluginCompatibility();
                break;
        }
    });

    $scope.$on('resolveLoadOrderNote', function(event, options) {
        switch(options.action) {
            case "move":
                var moveOptions = {
                    moveId: options.note.plugins[options.index].id,
                    destId: options.note.plugins[+!options.index].id,
                    after: !!options.index
                };
                $scope.$broadcast('moveItem', moveOptions);
                break;
            case "ignore":
                options.note.ignored = !options.note.ignored;
                // TODO: Update $scope.plugin_list.ignored_notes
                $scope.buildUnresolvedLoadOrder();
                break;
        }
    });

    // direct method trigger events
    $scope.$on('rebuildModels', $scope.buildPluginsModel);
    $scope.$on('rebuildMissingPlugins', $scope.buildMissingPlugins);
    $scope.$on('rebuildUnresolvedPluginCompatibility', $scope.buildUnresolvedPluginCompatibility);
    $scope.$on('rebuildUnresolvedLoadOrder', $scope.buildUnresolvedLoadOrder);
    $scope.$on('itemMoved', $scope.buildUnresolvedLoadOrder);
});