app.service('recordGroupService', function (backend, $q) {
    var thisService = this;
    this.retrieveRecordGroups = function (game_id) {
        return backend.retrieve('/record_groups', {game_id: game_id});
    };

    this.getGroupFromSignature = function (recordGroups, sig) {
        return recordGroups.find(function(group) {
            return group.signature === sig;
        });
    };

    this.associateGroups = function(plugins, game_id) {
        thisService.retrieveRecordGroups(game_id).then(function(allGroups) {
            plugins.forEach(function(plugin) {
                if (plugin.plugin_record_groups) {
                    plugin.plugin_record_groups.forEach(function(group) {
                        var record_group = thisService.getGroupFromSignature(allGroups, group.sig);
                        plugin.name = record_group.name;
                        plugin.child_group = record_group.child_group;
                    });
                }
            });
        });
    };
});
