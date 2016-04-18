app.service('userService', function (backend, $q) {
    this.retrieveUser = function (userId) {
        return backend.retrieve('/users/' + userId);
    };

});
