app.service('reviewSectionService', function (backend, $q) {
    this.retrieveReviewSections = function () {
        var reviewSections = $q.defer();

        backend.retrieve('/review_sections').then(function (data) {
            reviewSections.resolve(data);
        });

        return reviewSections.promise;
    };
});