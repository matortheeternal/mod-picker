app.service('tagService', function (backend, $q) {
    this.retrieveTags = function () {
        var tags = $q.defer();
        var postData =  {
            filters: {}
        };
        backend.post('/tags', postData).then(function (data) {
            tags.resolve(data);
        });
        return tags.promise;
    };

    this.updateModTags = function(mod, tags) {
        var putData = {
            game_id: mod.game_id,
            tags: tags
        };
        return backend.update('/mods/' + mod.id + '/tags', putData);
    };

    this.updateModListTags = function(mod_list, tags) {
        var putData = {
            game_id: mod_list.game_id,
            tags: tags
        };
        return backend.update('/mod_lists/' + mod_list.id + '/tags', putData);
    };
});