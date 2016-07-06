app.service('recordGroupService', function (backend, $q) {
    var service = this;
    this.retrieveRecordGroups = function () {
        return backend.retrieve('/record_groups', {game_id: window._current_game_id});
    };

    this.getGroupFromSignature = function (recordGroups, sig) {
        return recordGroups.find(function(group) {
            return group.signature === sig;
        });
    };

    // TODO: this is going to be a problem when we have multiple game modes on the site because this will be cached incorrectly, most likely
    var allRecordGroups = this.retrieveRecordGroups();

    this.associateGroups = function(plugins) {
        allRecordGroups.then(function(allGroups) {
            plugins.forEach(function(plugin) {
                if (plugin.plugin_record_groups) {
                    plugin.plugin_record_groups.forEach(function(group) {
                        var record_group = service.getGroupFromSignature(allGroups, group.sig);
                        group.name = record_group.name;
                        group.child_group = record_group.child_group;
                    });
                }
            });
        });
    };
});
