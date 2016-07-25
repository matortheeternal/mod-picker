app.controller('modReviewsController', function($scope, $stateParams, $timeout, $state, modService, reviewSectionService, contributionService, sortFactory) {
    $scope.sort = {
        column: $stateParams.scol,
        direction: $stateParams.sdir
    };
    $scope.pages = {};

    //loading the sort options
    $scope.sortOptions = sortFactory.reviewSortOptions();

    $scope.retrieveReviews = function(page) {
        // retrieve the reviews
        var options = {
            sort: $scope.sort,
            //if no page is specified load the first one
            page: page || 1
        };
        contributionService.retrieveModReviews($stateParams.modId, options, $scope.pages).then(function(data) {
            $scope.mod.reviews = data.reviews;
            $scope.mod.user_review = data.user_review;
        }, function(response) {
            $scope.errors.reviews = response;
        });

        //don't refresh the url on the first load
        if ($scope.loaded) {
            //refresh the tab's params
            var params = {
                scol: $scope.sort.column,
                sdir: $scope.sort.direction,
                page: page || 1
            };
            $scope.refreshTabParams('Reviews', params);
        } else {
            $timeout(function(){
                $scope.loaded = true;
            }, 100);
        }
    };
    //retrieve the reviews when the state is first loaded
    $scope.retrieveReviews($stateParams.page);

    //retrieve review sections
    reviewSectionService.getSectionsForCategory($scope.mod.primary_category).then(function(data) {
        $scope.reviewSections = data;
    }, function(response) {
        $scope.errors.reviewSections = response;
    });

    // re-retrieve reviews when the sort object changes
    $scope.$watch('sort', function() {
        $scope.retrieveReviews();
    }, true);

    // REVIEW RELATED LOGIC
    // instantiate a new review object
    $scope.startNewReview = function() {
        // set up activeReview object
        $scope.activeReview = {
            ratings: [],
            text_body: ""
        };

        // set up availableSections array
        $scope.availableSections = $scope.reviewSections.slice(0);

        // set up default review sections
        // and default text body with prompts
        $scope.reviewSections.forEach(function(section) {
            if (section.default) {
                $scope.addNewRating(section);
                $scope.activeReview.text_body += "## " + section.name + "\n";
                $scope.activeReview.text_body += "*" + section.prompt + "*\n\n";
            }
        });

        $scope.updateOverallRating();

        // update the markdown editor
        $scope.updateEditor();
    };

    // edit an existing review
    $scope.editReview = function(review) {
        review.editing = true;
        $scope.activeReview = {
            text_body: review.text_body.slice(0),
            moderator_message: review.moderator_message && review.moderator_message.slice(0),
            ratings: review.review_ratings.slice(0),
            overall_rating: review.overall_rating,
            original: review,
            editing: true
        };

        // set up availableSections array
        $scope.availableSections = $scope.reviewSections.filter(function(section) {
            return $scope.activeReview.ratings.find(function(rating) {
                return rating.section == section;
            }) === undefined;
        });

        // update validation, update the markdown editor
        $scope.validateReview();
        $scope.updateEditor();
    };

    // Add a new rating section to the activeReview
    $scope.addNewRating = function(section) {
        // return if we're at the maximum number of ratings
        if ($scope.activeReview.ratings.length >= 5 || $scope.availableSections.length === 0) {
            return;
        }

        // get the next available section if necessary
        section = section || $scope.getNextAvailableSection();
        // and remove it from the availableSections array
        $scope.availableSections = $scope.availableSections.filter(function(availableSection) {
            return availableSection.id !== section.id;
        });

        // build the rating object and append it to the ratings array
        var ratingObj = {
            section: section,
            rating: 100
        };
        $scope.activeReview.ratings.push(ratingObj);
    };

    //remove the section from reviewSections
    $scope.getNextAvailableSection = function() {
        return $scope.availableSections[0];
    };

    $scope.changeSection = function(newSection, oldSectionId) {
        if (newSection.id == oldSectionId) {
            return;
        }
        // psuh the oldSection onto the availableSections array
        var oldSection = $scope.reviewSections.find(function(section) {
            return section.id == oldSectionId;
        });
        $scope.availableSections.push(oldSection);
        // remove the new section from the availableSections array
        $scope.availableSections = $scope.availableSections.filter(function(availableSection) {
            return availableSection.id !== newSection.id;
        });

    };

    // remove a rating section from activeReview
    $scope.removeRating = function() {
        // return if we there's only one rating left
        if ($scope.activeReview.ratings.length == 1) {
            return;
        }

        // pop the last rating off of the ratings array
        var rating = $scope.activeReview.ratings.pop();
        // add the removed section back to the available list
        $scope.availableSections.push(rating.section);
    };

    $scope.validateReview = function() {
        $scope.activeReview.valid = $scope.activeReview.text_body.length > 512;
    };

    // discard a new review object
    $scope.discardReview = function() {
        if ($scope.activeReview.editing) {
            $scope.activeReview.original.editing = false;
            $scope.activeReview = null;
        } else {
            delete $scope.activeReview;
        }
    };

    // focus text in rating input
    $scope.focusText = function($event) {
        $event.target.select();
    };

    // update a review locally
    $scope.updateReview = function() {
        var originalReview = $scope.activeReview.original;
        var updatedReview = $scope.activeReview;
        // update the values on the original review
        originalReview.text_body = updatedReview.text_body.slice(0);
        originalReview.moderator_message = updatedReview.moderator_message && updatedReview.moderator_message.slice(0);
        originalReview.review_ratings = updatedReview.ratings.slice(0);
        originalReview.overall_rating = updatedReview.overall_rating;
    };

    // save a review
    $scope.saveReview = function() {
        // return if the review is invalid
        if (!$scope.activeReview.valid) {
            return;
        }

        // submit the review
        var review_ratings = [];
        $scope.activeReview.ratings.forEach(function(item) {
            review_ratings.push({
                review_section_id: item.section.id,
                rating: item.rating
            });
        });
        var reviewObj = {
            review: {
                game_id: $scope.mod.game_id,
                mod_id: $scope.mod.id,
                text_body: $scope.activeReview.text_body,
                edit_summary: $scope.activeReview.edit_summary,
                moderator_message: $scope.activeReview.moderator_message,
                review_ratings_attributes: review_ratings
            }
        };
        $scope.activeReview.submitting = true;

        // use update or submit contribution
        if ($scope.activeReview.editing) {
            var reviewId = $scope.activeReview.original.id;
            contributionService.updateContribution("reviews", reviewId, reviewObj).then(function() {
                $scope.$emit("successMessage", "Review updated successfully.");
                // update original review object and discard copy
                $scope.updateReview();
                $scope.discardReview();
            }, function(response) {
                var params = { label: 'Error updating Review', response: response };
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("reviews", reviewObj).then(function(review) {
                $scope.$emit("successMessage", "Review submitted successfully.");
                $scope.mod.user_review = review;
                $scope.discardReview();
            }, function(response) {
                var params = { label: 'Error submitting Review', response: response };
                $scope.$emit('errorMessage', params);
            });
        }
    };

    //update the average rating of the new review
    $scope.updateOverallRating = function() {
        var sum = 0;
        for (var i = 0; i < $scope.activeReview.ratings.length; i++) {
            sum += $scope.activeReview.ratings[i].rating;
        }

        $scope.activeReview.overall_rating = Math.round(sum / $scope.activeReview.ratings.length);
    };

    // functions for keeping rating inputs numerical and in the range 0->100
    $scope.keyPress = function($event) {
        var key = $event.keyCode;
        if (!(key >= 48 && key <= 57)) {
            $event.preventDefault();
        }
    };
    $scope.keyUp = function(review_rating) {
        var output = parseInt(review_rating.rating) || 0;
        review_rating.rating = output > 100 ? 100 : (output < 0 ? 0 : output);
        $scope.updateOverallRating();
    };
});
