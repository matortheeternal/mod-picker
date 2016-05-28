app.service('recordGroupService', function (backend, $q) {
    var service = this;
    this.retrieveRecordGroups = function (game_id) {
        return backend.retrieve('/record_groups', {game_id: game_id});
    };

    this.getGroupFromSignature = function (recordGroups, sig) {
        return recordGroups.find(function(group) {
            return group.signature === sig;
        });
    };

    this.associateGroups = function(plugins, game_id) {
        this.retrieveRecordGroups(game_id).then(function(groups) {
            plugins.forEach(function(plugin) {
                if (plugin.plugin_record_groups) {
                    plugin.plugin_record_groups.forEach(function(group) {
                        var record_group = service.getGroupFromSignature(groups, plugin.sig);
                        plugin.name = record_group.name;
                        plugin.child_group = record_group.child_group;
                    });
                }
            });
        });
    };
});
