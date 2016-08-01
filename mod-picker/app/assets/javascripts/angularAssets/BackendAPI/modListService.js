app.service('modListService', function (backend, $q, objectUtils, userTitleService, contributionService, categoryService) {
    this.retrieveModList = function(modListId) {
        return backend.retrieve('/mod_lists/' + modListId);
    };

    this.starModList = function(modListId, starred) {
        if (starred) {
            return backend.delete('/mod_lists/' + modListId + '/star');
        } else {
            return backend.post('/mod_lists/' + modListId + '/star', {});
        }
    };

    this.retrieveModListTools = function(modListId) {
        var action = $q.defer();
        backend.retrieve('/mod_lists/' + modListId + '/tools').then(function(data) {
            categoryService.associateCategories(data.tools);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveModListMods = function(modListId) {
        var action = $q.defer();
        backend.retrieve('/mod_lists/' + modListId + '/mods').then(function(data) {
            categoryService.associateCategories(data.mods);
            userTitleService.associateTitles(data.compatibility_notes);
            userTitleService.associateTitles(data.install_order_notes);
            contributionService.associateHelpfulMarks(data.compatibility_notes, data.c_helpful_marks);
            contributionService.associateHelpfulMarks(data.install_order_notes, data.i_helpful_marks);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveModListPlugins = function(modListId) {
        var action = $q.defer();
        backend.retrieve('/mod_lists/' + modListId + '/plugins').then(function(data) {
            categoryService.associateCategories(data.plugins);
            userTitleService.associateTitles(data.compatibility_notes);
            userTitleService.associateTitles(data.load_order_notes);
            contributionService.associateHelpfulMarks(data.compatibility_notes, data.c_helpful_marks);
            contributionService.associateHelpfulMarks(data.load_order_notes, data.l_helpful_marks);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.updateModList = function(modList) {
        var mod_list_mods = angular.copy(Array.prototype.concat(modList.tools || [], modList.mods || []));
        mod_list_mods.forEach(function(item) {
            if (item.mod) {
                delete item.mod;
            }
        });
        var mod_list_groups = angular.copy(modList.groups || []);
        mod_list_groups.forEach(function(group) {
            if (group.id && group.children) {
                delete group.children;
            } else if (group.children) {
                var newChildren = [];
                group.children.forEach(function(child) {
                    newChildren.push({id: child.id});
                });
                group.children = newChildren;
            }
        });
        var mod_list_plugins = angular.copy(modList.plugins || []);
        mod_list_plugins.forEach(function(item) {
            if (item.mod) {
                delete item.mod;
            }
            if (item.plugin) {
                delete item.plugin;
            }
        });

        var modListData = {
            mod_list: {
                id: modList.id,
                status: modList.status,
                visibility: modList.visibility,
                name: modList.name,
                description: modList.description,
                is_collection: modList.is_collection,
                disable_comments: modList.disable_comments,
                lock_tags: modList.lock_tags,
                hidden: modList.hidden,
                mod_list_groups_attributes: mod_list_groups,
                mod_list_mods_attributes: mod_list_mods,
                mod_list_plugins_attributes: mod_list_plugins,
                custom_plugins_attributes: modList.custom_plugins,
                ignored_notes_attributes: modList.ignored_notes
            }
        };
        objectUtils.deleteEmptyProperties(modListData, 1);

        return backend.update('/mod_lists/' + modList.id, modListData);
    };

    this.newModListMod = function(mod_list_mod) {
        var action = $q.defer();
        backend.post('/mod_list_mods', {mod_list_mod: mod_list_mod}).then(function(data) {
            userTitleService.associateTitles(data.compatibility_notes);
            userTitleService.associateTitles(data.install_order_notes);
            contributionService.associateHelpfulMarks(data.compatibility_notes, data.c_helpful_marks);
            contributionService.associateHelpfulMarks(data.install_order_notes, data.i_helpful_marks);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.newModListGroup = function(group) {
        return backend.post('/mod_list_groups', {mod_list_group: group});
    };

    this.cloneModList = function(modlist) {
        return backend.post('/mod_lists/clone/' + modlist.id, {});
    };

    this.deleteModList = function(modlist) {
        return backend.delete('/mod_lists/' + modlist.id);
    };
});
