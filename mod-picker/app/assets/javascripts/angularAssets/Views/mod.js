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

app.controller('modController', function ($scope, $q, $stateParams, $timeout, modService, pluginService, categoryService, gameService, userTitleService, assetUtils, reviewSectionService, userService) {
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
    modService.retrieveMod($stateParams.modId).then(function (mod) {
        $scope.mod = mod;
        $scope.statusClass = "status-" + mod.status;
        $scope.mod.status = mod.status.capitalize();

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

        //actions the user can perform
        var rep = $scope.user.reputation.overall;
        $scope.userCanAddMod = (rep >= 160) || ($scope.user.role === 'admin');
        $scope.userCanAddTags = (rep >= 20) || ($scope.user.role === 'admin');
    });

    //associate user titles with content
    $scope.associateUserTitles = function(data) {
        // if we don't have userTitles yet, try again in 100ms
        if (!$scope.userTitles) {
            $timeout(function() {
                $scope.associateUserTitles(data);
            }, 100);
            return;
        }
        // loop through data
        data.forEach(function(item) {
            if (item.user && !item.user.title) {
                item.user.title = userTitleService.getUserTitle($scope.userTitles, item.user.reputation.overall);
            }
        });
        return data;
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
        modService.retrieveReviews($stateParams.modId, options).then(function(reviews) {
            $scope.mod.reviews = $scope.associateUserTitles(reviews);
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
        modService.retrieveCompatibilityNotes($stateParams.modId, options).then(function(compatibility_notes) {
            $scope.mod.compatibility_notes = $scope.associateUserTitles(compatibility_notes);
        });
    };

    $scope.retrieveInstallOrderNotes = function() {
        var options = {
            sort: $scope.sort.compatibility_notes || 'reputation',
            filters: {
                mod_list: $scope.filters.install_order_notes
            }
        };
        modService.retrieveInstallOrderNotes($stateParams.modId, options).then(function(install_order_notes) {
            $scope.mod.install_order_notes = $scope.associateUserTitles(install_order_notes);
        });
    };

    $scope.retrieveLoadOrderNotes = function() {
        var options = {
            sort: $scope.sort.compatibility_notes || 'reputation',
            filters: {
                mod_list: $scope.filters.load_order_notes
            }
        };
        modService.retrieveLoadOrderNotes($stateParams.modId, options).then(function(load_order_notes) {
            $scope.mod.load_order_notes = $scope.associateUserTitles(load_order_notes);
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
        // TODO: Unimplemented
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
            text_body: ""
        };

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // discard the compatibility note object
    $scope.discardCompatibilityNote = function() {
        delete $scope.newCompatibilityNote;
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
});
