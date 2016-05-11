app.service('landingService', function (backend, $q) {
    this.retrieveLanding = function () {
        return backend.retrieve('/home', {game: 1}); //TODO: this needs to be generalized and get the current game instead of assuming skyrim
    };
});
