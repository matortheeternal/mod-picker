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
                is_collection: modList.is_collection,
                name: modList.name,
                description: modList.description,
                mod_list_mods_attributes: mod_list_mods
            }
        };
        objectUtils.deleteEmptyProperties(modListData, 1);

        return backend.update('/mod_lists/' + modList.id, modListData);
    };
});
