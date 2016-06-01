app.service('recordGroupService', function (backend, $q) {
    this.retrieveRecordGroups = function (game_id) {
        return backend.retrieve('/record_groups', {game_id: game_id});
    };

    this.getGroupFromSignature = function (recordGroups, sig) {
        return recordGroups.find(function(group) {
            return group.signature === sig;
        });
    };
});