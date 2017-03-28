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

    this.retrieveTagGroups = function() {
        var params = { game: window._current_game_id };
        return backend.retrieve('/tag_groups', params);
    };

    this.categoryTagGroups = function(tagGroups, categoryIds) {
        return tagGroups.filter(function(tagGroup) {
            return categoryIds.indexOf(tagGroup.category_id) > -1;
        });
    };

    this.hideTag = function(tagId, hidden) {
        return backend.post('/tags/' + tagId + '/hide', {hidden: hidden});
    };

    this.updateTag = function(tag) {
        var params = {
            tag: { text: tag.text }
        };
        return backend.update('/tags/' + tag.id, params);
    };

    this.replaceTag = function(oldTagId, newTagId) {
        return backend.post('/tags/' + oldTagId + '/replace', { new_tag_id: newTagId });
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

    this.getTagMatches = function(tags, str) {
        var matches = [];
        for (var i = 0; i < tags.length; i++) {
            var tag = tags[i];
            var match = tag.text.toLowerCase().includes(str);

            if (match) {
                matches[matches.length] = tag;
                if (matches.length == 10) break;
            }
        }
        return matches;
    };

    this.sortTagMatches = function(str, matches) {
        matches.sort(function(a, b) {
            var ax = a.text.toLowerCase().indexOf(str);
            var bx = b.text.toLowerCase().indexOf(str);
            return ax - bx;
        });
    };
});