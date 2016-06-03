app.service('userService', function (backend, $q, userSettingsService, userTitleService) {
    var thisService = this;
    this.retrieveUser = function (userId) {
        return backend.retrieve('/users/' + userId);
    };

    this.retrieveCurrentUser = function () {
        var output = $q.defer();
        backend.retrieve('/current_user').then(function (user) {
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

            user.permissions = this.getPermissions(user);

            output.resolve(user);
        };
        return output.promise;
    };

    this.getPermissions = function(user) {
        var permissions = {};
        permissions.isAdmin = user.role === 'admin';
        permissions.isModerator = user.role === 'moderator';
        // TODO: Remove this when beta is over
        permissions.canSubmitMod = true;
        //permissions.canSubmitMod = permissions.isAdmin || permissions.isModerator || user.reputation.overall > 160;
        return permissions;
    }
});
