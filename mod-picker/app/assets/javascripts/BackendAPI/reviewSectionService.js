app.service('reviewSectionService', function(backend, $q) {
    var service = this;

    this.retrieveReviewSections = function() {
        return backend.retrieve('/review_sections');
    };

    var allReviewSections = this.retrieveReviewSections();

    this.getSectionsForMod = function(mod) {
        var output = $q.defer();
        allReviewSections.then(function(reviewSections) {
            var sections = angular.copy(reviewSections);
            var modSections = sections.filter(function(section) {
                return (section.category_id === mod.primary_category.id) ||
                    (section.category_id === mod.primary_category.parent_id);
            });
            mod.secondary_category && sections.forEach(function(section) {
                if ((section.category_id === mod.secondary_category.id)
                    || (section.category_id === mod.secondary_category.parent_id)) {
                    // if section is already present, push prompt onto it
                    var foundSection = modSections.find(function(modSection) {
                        return modSection.name === section.name;
                    });
                    if (foundSection) {
                        if (foundSection.prompt !== section.prompt) {
                            foundSection.prompt += "  " + section.prompt;
                        }
                    } else {
                        section.default = false;
                        modSections.push(section);
                    }
                }
            });
            output.resolve(modSections);
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

    this.preparePrompt = function(section) {
        return '*' + section.prompt.replace(/\ /g, '\uFEFF ') + '*\n\n';
    };

    this.removePrompts = function(review_text_body) {
        return review_text_body.replace(/([^\n]+)\uFEFF([^\n]+)([\n]+)/g, '');
    };
});
