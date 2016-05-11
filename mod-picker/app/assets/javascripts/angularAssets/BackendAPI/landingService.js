app.service('landingService', function (backend, $q) {
    this.retrieveLanding = function () {
        return backend.retrieve('/home');
    };

});
