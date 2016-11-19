app.service('tagService', function(backend, $q, pageUtils) {
    this.retrieveAllTags = function() {
        var params = { game: window._current_game_id };
        return backend.retrieve('/all_tags', params);
    };

    this.retrieveTags = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/tags', options).then(function(data) {
            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.updateModTags = function(mod, tags) {
        var putData = {
            game_id: mod.game_id,
            tags: tags || []
        };
        return backend.update('/mods/' + mod.id + '/tags', putData);
    };

    this.updateModListTags = function(mod_list, tags) {
        var putData = {
            game_id: mod_list.game_id,
            tags: tags || []
        };
        return backend.update('/mod_lists/' + mod_list.id + '/tags', putData);
    };
});