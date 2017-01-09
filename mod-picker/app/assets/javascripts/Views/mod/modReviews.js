app.controller('modReviewsController', function($scope, $stateParams, $state, modService, reviewSectionService, contributionService, contributionFactory, sortFactory, formUtils, objectUtils) {
    $scope.sort.reviews = {
        column: $stateParams.scol,
        direction: $stateParams.sdir
    };

    // inherited functions
    $scope.focusText = formUtils.focusText;
    $scope.pages.reviews.current = $stateParams.page || 1;

    // BASE RETRIEVAL LOGIC
    $scope.retrieveReviews = function(page) {
        // retrieve the reviews
        var options = {
            sort: $scope.sort.reviews,
            page: page || $scope.pages.reviews.current
        };
        modService.retrieveModReviews($stateParams.modId, options, $scope.pages.reviews).then(function(data) {
            $scope.mod.reviews = data.reviews;
            if ($scope.errors.reviews) delete $scope.errors.reviews;
            if (data.user_review && objectUtils.isEmptyObject(data.user_review)) {
                $scope.userReviewHidden = true;
            } else {
                $scope.mod.user_review = data.user_review;

            }

            //seperating the review in the url if any
            if ($stateParams.reviewId) {
                var currentIndex = $scope.mod.reviews.findIndex(function(review) {
                    return review.id === $stateParams.reviewId;
                });
                if (currentIndex > -1) {
                    $scope.currentReview = $scope.mod.reviews.splice(currentIndex, 1)[0];
                } else {
                    // remove the reviewId param from the url if it's not part of this mod
                    $state.go($state.current.name, {reviewId: null});
                }
            } else {
                // clear the currentReview if it's not specified
                delete $scope.currentReview;
            }
        }, function(response) {
            $scope.errors.reviews = response;
        });

        //refresh the tab's params
        var params = {
            scol: $scope.sort.reviews.column,
            sdir: $scope.sort.reviews.direction,
            page: page || 1
        };
        $state.go($state.current.name, params);
    };

    //retrieve review sections
    reviewSectionService.getSectionsForMod($scope.mod).then(function(modSections) {
        $scope.reviewSections = modSections;
    }, function(response) {
        $scope.errors.reviewSections = response;
    });

    // re-retrieve reviews when the sort object changes
    // this will be called once automatically when the tab loads when we
    // build the sort object at line 2 in this controller
    $scope.$watch('sort.reviews', function() {
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
        $scope.reviewSections.forEach(function(section) {
            if (section.default) $scope.addNewRating(section);
        });

        // generate template and update overall rating
        $scope.updateOverallRating();
        $scope.generateEditorText();
    };

    $scope.generateEditorText = function() {
        // reset text body
        $scope.activeReview.text_body = "";

        // set up text body with prompts
        $scope.activeReview.ratings.forEach(function(rating) {
            var section = rating.section;
            $scope.activeReview.text_body += "## " + section.name + "\n";
            $scope.activeReview.text_body += contributionFactory.preparePrompt(section.prompt);
        });

        // update the markdown editor
        $scope.updateEditor();
    };

    // edit an existing review
    $scope.editReview = function(review) {
        review.editing = true;
        $scope.activeReview = {
            text_body: review.text_body.slice(0),
            moderator_message: review.moderator_message && review.moderator_message.slice(0),
            ratings: angular.copy(review.review_ratings),
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
            rating: null
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
        var review = $scope.activeReview;
        var sanitized_text = contributionService.removePrompts(review.text_body);
        var textValid = sanitized_text.length > 384;
        var ratingsValid = review.ratings.reduce(function(valid, section) {
            return valid && section.rating;
        }, true);
        $scope.activeReview.valid = textValid && ratingsValid;
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
        var review = $scope.activeReview;
        if (!review.valid) return;

        // submit the review
        var sanitized_text = contributionService.removePrompts(review.text_body);
        var review_ratings = [];
        review.ratings.forEach(function(item) {
            review_ratings.push({
                review_section_id: item.section.id,
                rating: item.rating
            });
        });
        var reviewObj = {
            review: {
                game_id: $scope.mod.game_id,
                mod_id: $scope.mod.id,
                text_body: sanitized_text,
                edit_summary: review.edit_summary,
                moderator_message: review.moderator_message,
                review_ratings_attributes: review_ratings
            }
        };
        review.submitting = true;

        // use update or submit contribution
        if (review.editing) {
            var reviewId = review.original.id;
            contributionService.updateContribution("reviews", reviewId, reviewObj).then(function() {
                $scope.$emit("successMessage", "Review updated successfully.");
                // update original review object and discard copy
                $scope.updateReview();
                $scope.discardReview();
                $scope.myReviewExpanded = true;
            }, function(response) {
                var params = { label: 'Error updating Review', response: response };
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("reviews", reviewObj).then(function(review) {
                $scope.$emit("successMessage", "Review submitted successfully.");
                $scope.mod.user_review = review;
                $scope.discardReview();
                $scope.myReviewExpanded = true;
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
        var key = (typeof $event.which == "number") ? $event.which : $event.keyCode;
        if (!(key >= 48 && key <= 57)) {
            $event.preventDefault();
        }
    };
    $scope.keyUp = function(review_rating) {
        if (review_rating.rating) {
            var output = parseInt(review_rating.rating) || 0;
            review_rating.rating = output > 100 ? 100 : (output < 0 ? 0 : output);
        }
        $scope.updateOverallRating();
    };
});
