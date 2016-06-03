app.service('userService', function (backend, $q) {
    this.retrieveUser = function (userId) {
        return backend.retrieve('/users/' + userId);
    };

    this.retrieveCurrentUser = function () {
        var user = $q.defer();
        backend.retrieve('/current_user').then(function (data) {
            user.resolve(data);
        });
        return user.promise;
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
