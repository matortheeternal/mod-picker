app.service('reviewSectionService', function (backend, $q) {
    var service = this;

    this.retrieveReviewSections = function () {
        try {
        	backend.retrieve('/review_sections').then(function (data) {
                return reviewSections.resolve(data);
        	});
        } catch (errors) {
        	throw errors;
        }
    };

    var allReviewSections = this.retrieveReviewSections();

    this.getSectionsForCategory = function(category) {
        var output = $q.defer();
        allReviewSections.then(function(sections) {
          output.resolve(sections.filter(function(section) {
              return (section.category_id === category.id) || (section.category_id === category.parent_id);
          }));
        });
        return output.promise;
    };

    this.getSectionById = function(sections, id) {
        return sections.find(function(section) {
            return (section.id === id);
        });
    };

    this.associateReviewSections = function(reviews) {
        return allReviewSections.then(function(sections) {
          reviews.forEach(function(review) {
            //set the category using the categoryId
            review.review_ratings.forEach(function(rating) {
                rating.section = service.getSectionById(sections, rating.review_section_id);
            });
          });
        });
    };
});
