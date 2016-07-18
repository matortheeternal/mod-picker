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

    this.updateModList = function(modList) {
        var mod_list_mods = Array.prototype.concat(modList.tools || [], modList.mods || []);
        var modListData = {
            mod_list: {
                id: modList.id,
                status: modList.status,
                visibility: modList.visibility,
                name: modList.name,
                description: modList.description,
                mod_list_mods_attributes: mod_list_mods,
                is_collection: modList.is_collection,
                disable_comments: modList.disable_comments,
                lock_tags: modList.lock_tags,
                hidden: modList.hidden
            }
        };
        objectUtils.deleteEmptyProperties(modListData, 1);

        return backend.update('/mod_lists/' + modList.id, modListData);
    };

    this.newModListMod = function(mod_id) {
        return backend.retrieve('/mod_list_mods/new', {mod_id: mod_id});
    }
});
