app.service('reviewSectionService', function (backend, $q) {
    var service = this;

    this.retrieveReviewSections = function () {
        return backend.retrieve('/review_sections');
    };

    var allReviewSections = this.retrieveReviewSections();

    this.getSectionsForCategory = function(category) {
        var output = $q.defer();
        allReviewSections.then(function(sections) {
          output.resolve(sections.filter(function(section) {
              return (section.category_id === category.id) || (section.category_id === category.parent_id);
          }));
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.getSectionById = function(id) {
        var output = $q.defer();
        allReviewSections.then(function(sections) {
            output.resolve(sections.find(function(section) {
                return (section.id === id);
            }));
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.associateReviewSections = function(reviews) {
      reviews.forEach(function(review) {
        //set the category using the categoryId
        review.review_ratings && review.review_ratings.forEach(function(rating) {
            service.getSectionById(rating.review_section_id).then(function(section) {
                rating.section = section;
            });
        });
      });
    };
});
