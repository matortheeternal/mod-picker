app.service('modListService', function (backend, objectUtils) {
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
        return backend.retrieve('/mod_lists/' + modListId + '/tools');
    };

    this.retrieveModListMods = function(modListId) {
        return backend.retrieve('/mod_lists/' + modListId + '/mods');
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
            } else {
                var newChildren = [];
                group.children.forEach(function(child) {
                    newChildren.push({id: child.id});
                });
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
                mod_list_mods_attributes: mod_list_mods,
                mod_list_groups_attributes: mod_list_groups
            }
        };
        objectUtils.deleteEmptyProperties(modListData, 1);

        return backend.update('/mod_lists/' + modList.id, modListData);
    };

    this.newModListMod = function(mod_id) {
        return backend.retrieve('/mod_list_mods/new', {mod_id: mod_id});
    }
});
