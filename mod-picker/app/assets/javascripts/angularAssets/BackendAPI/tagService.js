app.service('tagService', function (backend, $q) {
    this.retrieveTags = function () {
        var tags = $q.defer();

        var postData =  {
            filters: {}
        };

        backend.post('/tags', postData).then(function (data) {
            tags.resolve(data);
        });

        return tags.promise;
    };
});