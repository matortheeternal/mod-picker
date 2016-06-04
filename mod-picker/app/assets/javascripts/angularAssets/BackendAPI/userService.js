app.service('userService', function (backend, $q, userSettingsService, userTitleService) {
    var thisService = this;
    this.retrieveUser = function (userId) {
        var output = $q.defer();
        backend.retrieve('/users/' + userId).then(function(user) {
            //moving collections into a separate array
            user.collections = [];
            for (var i = user.mod_lists.length - 1; i >= 0; i--) {
                if (user.mod_lists[i].is_collection) {
                    user.collections.push(user.mod_lists.splice(i, 1)[0]);
                }
            }

            //get user title if it's not custom
            if (!user.title) {
                userTitleService.getUserTitle(user.reputation.overall).then(function(title) {
                    user.title = title;
                });
            }
            output.resolve(user);
        });
        return output.promise;
    };

    this.retrieveCurrentUser = function () {
        var output = $q.defer();
        backend.retrieve('/current_user').then(function (user) {
            user.permissions = thisService.getPermissions(user);
            output.resolve(user);
        });
        return output.promise;
    };

    this.getPermissions = function(user) {
        var permissions = {};
        var rep = user.reputation.overall;
        permissions.isAdmin = user.role === 'admin';
        permissions.isModerator = user.role === 'moderator';
        // TODO: Remove this when beta is over
        permissions.canSubmitMod = true;
        //permissions.canSubmitMod = permissions.isAdmin || permissions.isModerator || user.reputation.overall > 160;
        permissions.canChangeAvatar = (rep >= 10) || (permissions.isAdmin);
        permissions.canChangeTitle = (rep >= 1280) || (permissions.isAdmin);
        permissions.canCreateTags = (rep >= 20) || permissions.isAdmin || permissions.isModerator;
        permissions.canAppeal = (rep >= 40) || permissions.isModerator || permissions.isAdmin;
        permissions.canModerate = permissions.isModerator || permissions.isAdmin;

        var numEndorsed = 0; //TODO: retrieve the number of endorsements this user has made
        permissions.canEndorse = (rep >= 40 && numEndorsed <= 5) || (rep >= 160 && numEndorsed <= 10) || (rep >= 640 && numEndorsed <= 15);

        return permissions;
    };
});
