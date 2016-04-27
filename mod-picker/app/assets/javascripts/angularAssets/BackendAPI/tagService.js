app.service('tagService', function (backend, $q) {
    this.retrieveTags = function () {
        return backend.retrieve('/tags');
    };
});