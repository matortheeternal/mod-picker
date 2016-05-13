app.service('reviewSectionService', function (backend, $q) {
    this.retrieveReviewSections = function () {
        var reviewSections = $q.defer();

        backend.retrieve('/review_sections').then(function (data) {
            reviewSections.resolve(data);
        });

        return reviewSections.promise;
    };

    this.getSectionsForCategory = function(reviewSections, category) {
        return reviewSections.filter(function(section) {
            return (section.category_id == category.id) || (section.category_id == category.parent_id);
        });
    };

    this.getSectionById = function(reviewSections, id) {
        return reviewSections.find(function(section) {
            return (section.id == id);
        });
    };
});