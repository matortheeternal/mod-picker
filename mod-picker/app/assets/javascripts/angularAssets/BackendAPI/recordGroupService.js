app.service('recordGroupService', function (backend, $q) {
    var thisService = this;
    this.retrieveRecordGroups = function () {
        return backend.retrieve('/record_groups', {game_id: window._current_game_id});
    };

    this.getGroupFromSignature = function (recordGroups, sig) {
        return recordGroups.find(function(group) {
            return group.signature === sig;
        });
    };

    var allRecordGroups = this.retrieveRecordGroups();

    this.associateGroups = function(plugins) {
        allRecordGroups.then(function(allGroups) {
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
