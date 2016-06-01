app.service('reviewSectionService', function (backend, $q, $timeout) {
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

    // associate reviews with review sections
    this.associateReviewSections = function(reviews, reviewSections, allReviewSections) {
        var service = this;
        // if we don't have review sections yet, try again in 100ms
        if (reviewSections.length == 0 || allReviewSections.length == 0) {
            $timeout(function() {
                service.associateReviewSections(reviews, reviewSections, allReviewSections);
            }, 100);
            return;
        }
        // loop through the reviews
        reviews.forEach(function(review) {
            review.review_ratings.forEach(function(rating) {
                rating.section = service.getSectionById(allReviewSections, rating.review_section_id);
            });
        });
    };
});