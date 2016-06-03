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

});
