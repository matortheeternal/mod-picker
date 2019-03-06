app.service('premiumService', function(backend) {
    this.retrieveOptions = function() {
        return backend.retrieve('/premium_options');
    };
});
