app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('mod', {
            templateUrl: '/resources/partials/showMod/mod.html',
            controller: 'modController',
            url: '/mod/:modId'
        }
    );
}]);

//TODO: belongs in its own filter
app.filter('percentage', function() {
  return function(input) {
    if (isNaN(input)) {
      return input;
    }
    return Math.floor(input * 100) + '%';
  };
});

app.controller('modController', function ($scope, $q, $stateParams, $timeout, modService, pluginService, categoryService, gameService, userTitleService, assetUtils, reviewSectionService, userService, contributionService, contributionFactory) {
    $scope.tags = [];
    $scope.newTags = [];
    $scope.sort = {};
    $scope.filters = {
        compatibility_notes: true,
        install_order_notes: true,
        load_order_notes: true
    };

    // SETUP AND DATA RETRIEVAL LOGIC
    //initialization of the mod object
    modService.retrieveMod($stateParams.modId).then(function (data) {
        var mod = data.mod;
        $scope.mod = mod;
        $scope.modStarred = data.star;
        switch (mod.status) {
            case "good":
                $scope.statusClass = "green-box";
                break;
            case "outdated":
                $scope.statusClass = "yellow-box";
                break;
            case "dangerous":
                $scope.statusClass = "red-box";
                break;
        }

        // getting categories
        categoryService.retrieveCategories().then(function (categories) {
            $scope.primaryCategory = categoryService.getCategoryById(categories, mod.primary_category_id);
            $scope.secondaryCategory = categoryService.getCategoryById(categories, mod.secondary_category_id);

            // getting review sections
            reviewSectionService.retrieveReviewSections().then(function (reviewSections) {
                $scope.allReviewSections = reviewSections;
                $scope.reviewSections = reviewSectionService.getSectionsForCategory(reviewSections, $scope.primaryCategory);
                $scope.associateReviewSections();
            });
        });

        // getting games
        gameService.retrieveGames().then(function (data) {
            $scope.game = gameService.getGameById(data, mod.game_id);
        });
    });

    //get user titles
    userTitleService.retrieveUserTitles().then(function(userTitles) {
        $scope.userTitles = userTitleService.getSortedGameTitles(userTitles);
    });

    //get current user
    userService.retrieveThisUser().then(function (user) {
        $scope.user = user;
        $scope.getPermissions();
    });

    //get user permissions
    $scope.getPermissions = function() {
        // if we don't have mod yet, try again in 100ms
        if (!$scope.mod) {
            $timeout(function() {
                $scope.getPermissions();
            }, 100);
            return;
        }

        // set up helper variables
        var author = $scope.mod.authors.find(function(author) {
            return author.id == $scope.user.id;
        });
        var rep = $scope.user.reputation.overall;
        var isAdmin = $scope.user.role === 'admin';
        var isModerator = $scope.user.role === 'moderator';
        var isAuthor = author !== null;

        // set up permissions
        $scope.permissions = {
            canCreateTags: (rep >= 20) || isAdmin || isModerator,
            canManage: isAuthor || isModerator || isAdmin,
            canSuggest: (rep >= 40),
            canModerate: isModerator || isAdmin
        }
    };

    //associate user titles with content
    $scope.associateUserTitles = function(data) {
        // if we don't have userTitles yet, try again in 100ms
        if (!$scope.userTitles) {
            $timeout(function() {
                $scope.associateUserTitles(data);
            }, 100);
            return;
        }

        // associate titles with the data
        userTitleService.associateTitles($scope.userTitles, data);

        // return modified data
        return data;
    };

    //associate helpful marks with content
    $scope.associateHelpfulMarks = function(data, helpfulMarks) {
        // loop through data
        data.forEach(function(item) {
            // see if we have a matching helpful mark
            var helpfulMark = helpfulMarks.find(function(mark) {
                return mark.helpfulable_id == item.id;
            });
            // if we have a matching helpful mark, assign it to the item
            if (helpfulMark) {
                item.helpful = helpfulMark.helpful;
            }
        });
    };

    // TAB RELATED LOGIC
    //set up tab data
    //TODO use the cool ui-router here :D
    $scope.tabs = [
        { name: 'Reviews', url: '/resources/partials/showMod/reviews.html' },
        { name: 'Compatibility', url: '/resources/partials/showMod/compatibility.html' },
        { name: 'Install Order', url: '/resources/partials/showMod/installOrder.html' },
        { name: 'Load Order', url: '/resources/partials/showMod/loadOrder.html' },
        { name: 'Analysis', url: '/resources/partials/showMod/analysis.html' }
    ];

    $scope.currentTab = $scope.tabs[0];

    $scope.switchTab = function(targetTab) {
        switch (targetTab.name) {
            case 'Reviews':
                if ($scope.mod.reviews == null) {
                    $scope.retrieveReviews();
                }
                break;
            case 'Compatibility':
                if ($scope.mod.compatibility_notes == null) {
                    $scope.retrieveCompatibilityNotes();
                }
                break;
            case 'Install Order':
                if ($scope.mod.install_order_notes == null) {
                    $scope.retrieveInstallOrderNotes();
                }
                break;
            case 'Load Order':
                if ($scope.mod.load_order_notes == null) {
                    $scope.retrieveLoadOrderNotes();
                }
                break;
            case 'Analysis':
                if ($scope.mod.analysis == null) {
                    $scope.retrieveAnalysis();
                }
                break;
        }
    };

    $scope.retrieveReviews = function() {
        var options = {
            sort: $scope.sort.reviews || 'reputation'
        };
        modService.retrieveReviews($stateParams.modId, options).then(function(data) {
            $scope.associateHelpfulMarks(data.reviews, data.helpful_marks);
            $scope.mod.reviews = $scope.associateUserTitles(data.reviews);
            $scope.associateReviewSections();
        });
    };

    $scope.retrieveCompatibilityNotes = function() {
        var options = {
            sort: $scope.sort.compatibility_notes || 'reputation',
            filters: {
                mod_list: $scope.filters.compatibility_notes || true
            }
        };
        modService.retrieveCompatibilityNotes($stateParams.modId, options).then(function(data) {
            $scope.associateHelpfulMarks(data.compatibility_notes, data.helpful_marks);
            $scope.mod.compatibility_notes = $scope.associateUserTitles(data.compatibility_notes);
        });
    };

    $scope.retrieveInstallOrderNotes = function() {
        var options = {
            sort: $scope.sort.compatibility_notes || 'reputation',
            filters: {
                mod_list: $scope.filters.install_order_notes
            }
        };
        modService.retrieveInstallOrderNotes($stateParams.modId, options).then(function(data) {
            $scope.associateHelpfulMarks(data.install_order_notes, data.helpful_marks);
            $scope.mod.install_order_notes = $scope.associateUserTitles(data.install_order_notes);
        });
    };

    $scope.retrieveLoadOrderNotes = function() {
        var options = {
            sort: $scope.sort.compatibility_notes || 'reputation',
            filters: {
                mod_list: $scope.filters.load_order_notes
            }
        };
        modService.retrieveLoadOrderNotes($stateParams.modId, options).then(function(data) {
            $scope.associateHelpfulMarks(data.load_order_notes, data.helpful_marks);
            $scope.mod.load_order_notes = $scope.associateUserTitles(data.load_order_notes);
        });
    };

    $scope.retrieveAnalysis = function() {
        modService.retrieveAnalysis($stateParams.modId).then(function(analysis) {
            analysis.nestedAssets = assetUtils.convertDataStringToNestedObject(analysis.assets);
            $scope.mod.analysis = analysis;
        });
    };

    // HEADER RELATED LOGIC
    $scope.starMod = function() {
        modService.starMod($scope.mod.id, $scope.modStarred).then(function(data) {
            if (data.status == 'ok') {
                $scope.modStarred = $scope.modStarred ? false : true;
            }
        });
    };

    // REVIEW RELATED LOGIC
    // retrieve reviews initially because they're the default tab currently
    $scope.retrieveReviews();

    // associate reviews with review sections
    $scope.associateReviewSections = function() {
        if ($scope.mod.reviews && $scope.reviewSections) {
            $scope.mod.reviews.forEach(function(review) {
                review.review_ratings.forEach(function(rating) {
                    rating.section = reviewSectionService.getSectionById($scope.allReviewSections, rating.review_section_id);
                });
            });
        }
    };

    // instantiate a new review object
    $scope.startNewReview = function() {
        // set up newReview object
        $scope.newReview = {
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
                $scope.newReview.text_body += "## " + section.name + "\n";
                $scope.newReview.text_body += "*" + section.prompt + "*\n\n";
            }
        });

        $scope.updateOverallRating();

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // Add a new rating section to the newReview
    $scope.addNewRating = function(section) {
        // return if we're at the maximum number of ratings
        if ($scope.newReview.ratings.length >= 5 || $scope.availableSections.length == 0) {
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
        $scope.newReview.ratings.push(ratingObj);
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

    // remove a rating section from newReview
    $scope.removeRating = function() {
        // return if we there's only one rating left
        if ($scope.newReview.ratings.length == 1) {
            return;
        }

        // pop the last rating off of the ratings array
        var rating = $scope.newReview.ratings.pop();
        // add the removed section back to the available list
        $scope.availableSections.push(rating.section);
    };

    $scope.validateReview = function() {
        $scope.newReview.valid = $scope.newReview.text_body.length > 512;
    };

    // discard a new review object
    $scope.discardReview = function() {
        delete $scope.newReview;
    };

    // focus text in rating input
    $scope.focusText = function ($event) {
        $event.target.select();
    };

    // submit a review
    $scope.submitReview = function() {
        // return if the review is invalid
        if (!$scope.newReview.valid) {
            return;
        }

        // submit the review
        var review_ratings = [];
        $scope.newReview.ratings.forEach(function(item) {
            review_ratings.push({
                review_section_id: item.section.id,
                rating: item.rating
            });
        });
        var reviewObj = {
            review: {
                game_id: $scope.mod.game_id,
                mod_id: $scope.mod.id,
                text_body: $scope.newReview.text_body,
                review_ratings_attributes: review_ratings
            }
        };
        $scope.newReview.submitting = true;
        contributionService.submitContribution("reviews", reviewObj).then(function(data) {
            if (data.status == "ok") {
                $scope.submitMessage = "Review submitted successfully!";
                $scope.showSuccess = true;
                // TODO: push the review onto the $scope.mod.reviews array
                delete $scope.newReview;
            }
        });
    };

    //update the average rating of the new review
    $scope.updateOverallRating = function() {
        //TODO: this might become ressource heavy on mods with many ratings.
        //TODO: Reply - this isn't looping through all the reviews, it's looping through the sections of a single review.  It's still not necessary though because we can do the math in the view model I think.  -Mator
        // possible solution: (overallRating * number of ratings + newRating) / number of ratings + 1
        var sum = 0;
        for (var i = 0; i<$scope.newReview.ratings.length; i++) {
            sum += $scope.newReview.ratings[i].rating;
        }

        $scope.newReview.overallRating = Math.round(sum/$scope.newReview.ratings.length);
    };

    //removes all non numbers and rounds to the nearest int and doesn't go above 100 or below 0
    $scope.formatScore = function(input) {
        var output = input;
        output = output.replace(/[^\d\.]/g, '');
        output = Math.round(output);
        if (output > 100) {
            output = 100;
        }
        else if (output < 0) {
            output = 0;
        }
        return output;
    };

    // COMPATIBILITY NOTE RELATED LOGIC
    // instantiate a new compatibility note object
    $scope.startNewCompatibilityNote = function() {
        // set up newCompatibilityNote object
        $scope.newCompatibilityNote = {
            compatibility_type: "incompatible",
            text_body: contributionFactory.getDefaultTextBody("CompatibilityNote")
        };

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    $scope.validateCompatibilityNote = function() {
        $scope.newCompatibilityNote.valid = $scope.newCompatibilityNote.text_body.length > 512 &&
            ($scope.newCompatibilityNote.second_mod_id !== undefined) &&
            ($scope.newCompatibilityNote.compatibility_type === "compatibility mod") ==
            ($scope.newCompatibilityNote.compatibility_mod !== undefined);
    };

    // discard the compatibility note object
    $scope.discardCompatibilityNote = function() {
        delete $scope.newCompatibilityNote;
    };

    // submit a compatibility note
    $scope.submitCompatibilityNote = function() {
        // return if the compatibility note is invalid
        if (!$scope.newCompatibilityNote.valid) {
            return;
        }

        // submit the compatibility note
        var noteObj = {
            compatibility_note: {
                game_id: $scope.mod.game_id,
                compatibility_type: $scope.newCompatibilityNote.compatibility_type,
                first_mod_id: $scope.mod.id,
                second_mod_id: $scope.newCompatibilityNote.second_mod_id,
                text_body: $scope.newCompatibilityNote.text_body,
                compatibility_plugin_id: $scope.newCompatibilityNote.compatibility_plugin_id,
                compatibility_mod_id: $scope.newCompatibilityNote.compatibility_mod_id
            }
        };
        $scope.newCompatibilityNote.submitting = true;
        contributionService.submitContribution("compatibility_notes", noteObj).then(function(data) {
            if (data.status == "ok") {
                $scope.submitMessage = "Compatibility Note submitted successfully!";
                $scope.showSuccess = true;
                // TODO: push the compatibility note onto the $scope.mod.compatibility_notes array
                delete $scope.newCompatibilityNote;
            }
        });
    };

    // INSTALL ORDER NOTE RELATED LOGIC
    // instantiate a new install order note object
    $scope.startNewInstallOrderNote = function() {
        // set up newReview object
        $scope.newInstallOrderNote = {
            order: "before",
            text_body: ""
        };

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // discard the install order note object
    $scope.discardInstallOrderNote = function() {
        delete $scope.newInstallOrderNote;
    };

    // LOAD ORDER NOTE RELATED LOGIC
    // instantiate a new load order note object
    $scope.startNewLoadOrderNote = function() {
        // set up newReview object
        $scope.newLoadOrderNote = {
            order: "before",
            text_body: ""
        };

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // discard the load order note object
    $scope.discardLoadOrderNote = function() {
        delete $scope.newLoadOrderNote;
    };
});
