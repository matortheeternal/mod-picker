app.service('userService', function (backend, $q) {
    this.retrieveUser = function (userId) {
        var user = $q.defer();
        backend.retrieve('/users/' + userId).then(function (data) {
            //TODO: remove mocked delay
            setTimeout(function () {
                user.resolve(data);
            }, 1000);
        });
        return user.promise;
    };

});
