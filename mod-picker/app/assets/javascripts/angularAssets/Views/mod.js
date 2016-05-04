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

app.controller('modController', function ($scope, $q, $stateParams, modService, pluginService, categoryService, gameService, assetUtils, reviewSectionService, userService) {
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
                $scope.reviewSections = reviewSectionService.getSectionsForCategory(reviewSections, $scope.primaryCategory);
            });
        });

        // getting games
        gameService.retrieveGames().then(function (data) {
            $scope.game = gameService.getGameById(data, mod.game_id);
        });

        // retrieve notes
        //TODO: This should happen when we switch tabs
        modService.retrieveCompatibilityNotes(mod.id).then(function(notes) {
            $scope.compatibilityNotes = notes;
        });
        modService.retrieveInstallOrderNotes(mod.id).then(function(notes) {
            $scope.installOrderNotes = notes;
        });
        modService.retrieveLoadOrderNotes(mod.id).then(function(notes) {
            $scope.loadOrderNotes = notes;
        });
    });

    //get current user
    userService.retrieveThisUser().then(function (user) {
        $scope.user = user;

        //actions the user can perform
        var rep = $scope.user.reputation.overall;
        $scope.userCanAddMod = (rep >= 160) || ($scope.user.role === 'admin');
        $scope.userCanAddTags = (rep >= 20) || ($scope.user.role === 'admin');
    });

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
            // DO NOT DELETE - MAY BE USED AT A FUTURE DATE
            /*case 'Reviews':
                if ($scope.mod.reviews == null) {
                    $scope.retrieveReviews();
                }
                break;*/
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

    // DO NOT DELETE - MAY BE USED AT A FUTURE DATE
    /*$scope.retrieveReviews = function() {
        var options = {
            sort: $scope.sort.reviews || 'reputation'
        };
        modService.retrieveReviews($scope.mod.id, options).then(function(reviews) {
            $scope.mod.reviews = reviews;
        });
    };*/

    $scope.retrieveCompatibilityNotes = function() {
        var options = {
            sort: $scope.sort.compatibility_notes || 'reputation',
            filters: {
                mod_list: $scope.filters.compatibility_notes || true
            }
        };
        modService.retrieveCompatibilityNotes($scope.mod.id, options).then(function(compatibility_notes) {
            $scope.mod.compatibility_notes = compatibility_notes;
        });
    };

    $scope.retrieveInstallOrderNotes = function() {
        var options = {
            sort: $scope.sort.compatibility_notes || 'reputation',
            filters: {
                mod_list: $scope.filters.install_order_notes
            }
        };
        modService.retrieveInstallOrderNotes($scope.mod.id, options).then(function(install_order_notes) {
            $scope.mod.install_order_notes = install_order_notes;
        });
    };

    $scope.retrieveLoadOrderNotes = function() {
        var options = {
            sort: $scope.sort.compatibility_notes || 'reputation',
            filters: {
                mod_list: $scope.filters.load_order_notes
            }
        };
        modService.retrieveLoadOrderNotes($scope.mod.id, options).then(function(load_order_notes) {
            $scope.mod.load_order_notes = load_order_notes;
        });
    };

    $scope.retrieveAnalysis = function() {
        modService.retrieveAnalysis($scope.mod.id).then(function(analysis) {
            analysis.nestedAssets = assetUtils.convertDataStringToNestedObject(analysis.assets);
            $scope.mod.analysis = analysis;
        });
    };

    // REVIEW RELATED LOGIC
    // instantiate a new review object
    $scope.startNewReview = function() {
        // set up newReview object
        $scope.newReview = {
            ratings: [],
            text_body: ""
        };
        // set up default review sections
        // and default text body with prompts
        $scope.reviewSections.forEach(function(section) {
            if (section.default) {
                var ratingObj = {
                    section: section,
                    rating: 50
                };
                $scope.newReview.ratings.push(ratingObj);
                $scope.newReview.text_body += "## " + section.name + "\n";
                $scope.newReview.text_body += "*" + section.prompt + "*\n\n";
            }
        });

        $scope.updateOverallRating();
    };

    // discard a new review object
    $scope.discardNewReview = function() {
        delete $scope.newReview;
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
});
