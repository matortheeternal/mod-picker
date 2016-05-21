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

app.controller('modController', function ($scope, $q, $stateParams, $timeout, modService, pluginService, categoryService, gameService, recordGroupService, userTitleService, assetUtils, reviewSectionService, userService, contributionService, contributionFactory) {
    $scope.tags = [];
    $scope.newTags = [];
    $scope.sort = {};
    $scope.filters = {
        compatibility_notes: true,
        install_order_notes: true,
        load_order_notes: true
    };

    // SETUP TABS
    //TODO use the cool ui-router here :D
    $scope.tabs = [
        { name: 'Reviews', url: '/resources/partials/showMod/reviews.html' },
        { name: 'Compatibility', url: '/resources/partials/showMod/compatibility.html' },
        { name: 'Install Order', url: '/resources/partials/showMod/installOrder.html' },
        { name: 'Load Order', url: '/resources/partials/showMod/loadOrder.html' },
        { name: 'Analysis', url: '/resources/partials/showMod/analysis.html' }
    ];

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
            });
        });

        // getting games
        gameService.retrieveGames().then(function (data) {
            $scope.game = gameService.getGameById(data, mod.game_id);
        });

        // remove Load Order tab if mod has no plugins
        if ($scope.mod.plugins_count == 0) {
            $scope.tabs.splice(3, 1);
        }
    });

    //get user titles
    userTitleService.retrieveUserTitles().then(function(userTitles) {
        $scope.userTitles = userTitleService.getSortedGameTitles(userTitles);
    });

    //get record groups
    recordGroupService.retrieveRecordGroups(window._current_game_id).then(function(recordGroups) {
        $scope.recordGroups = recordGroups;
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

    //associate record groups with plugins
    $scope.associateRecordGroups = function(plugins) {
        // if we don't have recordGroups yet, try again in 100ms
        if (!$scope.recordGroups) {
            $timeout(function() {
                $scope.associateRecordGroups(plugins);
            }, 100);
            return;
        }
        // loop through plugins
        plugins.forEach(function(plugin) {
            if (plugin.plugin_record_groups) {
                plugin.plugin_record_groups.forEach(function(group) {
                    var record_group = recordGroupService.getGroupFromSignature($scope.recordGroups, group.sig);
                    group.name = record_group.name;
                    group.child_group = record_group.child_group;
                });
            }
        });
    };

    //combine dummy_masters array with masters array and sorts the masters array
    $scope.combineAndSortMasters = function(plugins) {
        // loop through plugins
        plugins.forEach(function(plugin) {
            plugin.masters = plugin.masters.concat(plugin.dummy_masters);
            plugin.masters.sort(function(first_master, second_master) {
                return first_master.index - second_master.index;
            });
        });
    };

    //associate overrides with their master file
    $scope.associateOverrides = function(plugins) {
        // loop through plugins
        plugins.forEach(function(plugin) {
            plugin.masters.forEach(function(master) {
                master.overrides = [];
                plugin.overrides.forEach(function(override) {
                    if (override.fid >= master.index * 0x01000000) {
                        master.overrides.push(override);
                    }
                });
            });
        });
    };

    // TAB RELATED LOGIC
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
            $scope.associateUserTitles(data.reviews);
            $scope.associateReviewSections(data.reviews);
            $scope.mod.reviews = data.reviews;
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
            $scope.associateUserTitles(data.compatibility_notes);
            $scope.mod.compatibility_notes = data.compatibility_notes;
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
            $scope.associateUserTitles(data.install_order_notes);
            $scope.mod.install_order_notes = data.install_order_notes;
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
            $scope.associateUserTitles(data.load_order_notes);
            $scope.mod.load_order_notes = data.load_order_notes;
        });
    };

    $scope.retrieveAnalysis = function() {
        modService.retrieveAnalysis($stateParams.modId).then(function(analysis) {
            // turn assets into an array of string
            $scope.mod.assets = analysis.assets.map(function(asset) {
                return asset.filepath;
            });
            // create nestedAssets tree
            $scope.mod.nestedAssets = assetUtils.convertDataStringToNestedObject($scope.mod.assets);

            // associate record groups for plugins
            $scope.associateRecordGroups(analysis.plugins);
            $scope.combineAndSortMasters(analysis.plugins);
            $scope.associateOverrides(analysis.plugins);
            $scope.mod.plugins = analysis.plugins;
            if ($scope.mod.plugins.length > 0) {
                $scope.currentPlugin = analysis.plugins[0];
                $scope.currentPluginFilename = analysis.plugins[0].filename;
            }
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
    $scope.associateReviewSections = function(reviews) {
        // if we don't have recordGroups yet, try again in 100ms
        if (!$scope.reviewSections) {
            $timeout(function() {
                $scope.associateReviewSections(reviews);
            }, 100);
            return;
        }
        // loop through the reviews
        reviews.forEach(function(review) {
            review.review_ratings.forEach(function(rating) {
                rating.section = reviewSectionService.getSectionById($scope.allReviewSections, rating.review_section_id);
            });
        });
    };

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
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // edit an existing review
    $scope.editReview = function(review) {
        review.editing = true;
        $scope.activeReview = {
            text_body: review.text_body,
            ratings: review.review_ratings,
            overallRating: review.overall_rating,
            original: review
        };

        // set up availableSections array
        $scope.availableSections = $scope.reviewSections.filter(function(section) {
            return $scope.activeReview.ratings.find(function(rating) {
                return rating.section == section;
            }) == undefined;
        });

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // Add a new rating section to the activeReview
    $scope.addNewRating = function(section) {
        // return if we're at the maximum number of ratings
        if ($scope.activeReview.ratings.length >= 5 || $scope.availableSections.length == 0) {
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
        if ($scope.activeReview.original) {
            $scope.activeReview.original.editing = false;
            $scope.activeReview = null;
        } else {
            delete $scope.activeReview;
        }
    };

    // focus text in rating input
    $scope.focusText = function ($event) {
        $event.target.select();
    };

    // submit a review
    $scope.submitReview = function() {
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
                review_ratings_attributes: review_ratings
            }
        };
        $scope.activeReview.submitting = true;
        contributionService.submitContribution("reviews", reviewObj).then(function(data) {
            if (data.status == "ok") {
                $scope.submitMessage = "Review submitted successfully!";
                $scope.showSuccess = true;
                // TODO: push the review onto the $scope.mod.reviews array
                delete $scope.activeReview;
            }
        });
    };

    //update the average rating of the new review
    $scope.updateOverallRating = function() {
        //TODO: this might become ressource heavy on mods with many ratings.
        //TODO: Reply - this isn't looping through all the reviews, it's looping through the sections of a single review.  It's still not necessary though because we can do the math in the view model I think.  -Mator
        // possible solution: (overallRating * number of ratings + newRating) / number of ratings + 1
        var sum = 0;
        for (var i = 0; i<$scope.activeReview.ratings.length; i++) {
            sum += $scope.activeReview.ratings[i].rating;
        }

        $scope.activeReview.overallRating = Math.round(sum / $scope.activeReview.ratings.length);
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
        // set up activeCompatibilityNote object
        $scope.activeCompatibilityNote = {
            compatibility_type: "incompatible",
            text_body: contributionFactory.getDefaultTextBody("CompatibilityNote")
        };

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // edit an existing compatibility note
    $scope.editCompatibilityNote = function(compatibility_note) {
        compatibility_note.editing = true;
        var secondMod = compatibility_note.mods.find(function(mod) {
            return mod.id !== $scope.mod.id;
        });
        $scope.activeCompatibilityNote = {
            compatibility_type: compatibility_note.compatibility_type,
            mod_id: secondMod.id,
            mod_name: secondMod.name,
            compatibility_mod_id: compatibility_note.compatibility_mod_id,
            compatibility_plugin_id: compatibility_note.compatibility_plugin_id,
            text_body: compatibility_note.text_body,
            original: compatibility_note
        };

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    $scope.validateCompatibilityNote = function() {
        // exit if we don't have a activeCompatibilityNote yet
        if (!$scope.activeCompatibilityNote) {
            return;
        }

        $scope.activeCompatibilityNote.valid = $scope.activeCompatibilityNote.text_body.length > 512 &&
            ($scope.activeCompatibilityNote.second_mod_id !== undefined) &&
            ($scope.activeCompatibilityNote.compatibility_type === "compatibility mod") ==
            ($scope.activeCompatibilityNote.compatibility_mod !== undefined);
    };

    // discard the compatibility note object
    $scope.discardCompatibilityNote = function() {
        if ($scope.activeCompatibilityNote.original) {
            $scope.activeCompatibilityNote.original.editing = false;
            $scope.activeCompatibilityNote = null;
        } else {
            delete $scope.activeCompatibilityNote;
        }
    };

    // submit a compatibility note
    $scope.submitCompatibilityNote = function() {
        // return if the compatibility note is invalid
        if (!$scope.activeCompatibilityNote.valid) {
            return;
        }

        // submit the compatibility note
        var noteObj = {
            compatibility_note: {
                game_id: $scope.mod.game_id,
                compatibility_type: $scope.activeCompatibilityNote.compatibility_type,
                first_mod_id: $scope.mod.id,
                second_mod_id: $scope.activeCompatibilityNote.mod_id,
                text_body: $scope.activeCompatibilityNote.text_body,
                compatibility_plugin_id: $scope.activeCompatibilityNote.compatibility_plugin_id,
                compatibility_mod_id: $scope.activeCompatibilityNote.compatibility_mod_id
            }
        };
        $scope.activeCompatibilityNote.submitting = true;
        contributionService.submitContribution("compatibility_notes", noteObj).then(function(data) {
            if (data.status == "ok") {
                $scope.submitMessage = "Compatibility Note submitted successfully!";
                $scope.showSuccess = true;
                // TODO: push the compatibility note onto the $scope.mod.compatibility_notes array
                delete $scope.activeCompatibilityNote;
            }
        });
    };

    // INSTALL ORDER NOTE RELATED LOGIC
    // instantiate a new install order note object
    $scope.startNewInstallOrderNote = function() {
        // set up activeInstallOrderNote object
        $scope.activeInstallOrderNote = {
            order: "before",
            text_body: ""
        };

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // edit an existing install order note
    $scope.editInstallOrderNote = function(install_order_note) {
        install_order_note.editing = true;
        $scope.activeInstallOrderNote = install_order_note;

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    $scope.validateInstallOrderNote = function() {
        // exit if we don't have a activeInstallOrderNote yet
        if (!$scope.activeInstallOrderNote) {
            return;
        }

        $scope.activeInstallOrderNote.valid = $scope.activeInstallOrderNote.text_body.length > 512 &&
            ($scope.activeInstallOrderNote.mod_id !== undefined);
    };

    // discard the install order note object
    $scope.discardInstallOrderNote = function() {
        if ($scope.activeInstallOrderNote.editing) {
            $scope.activeInstallOrderNote.editing = false;
            $scope.activeInstallOrderNote = null;
        } else {
            delete $scope.activeInstallOrderNote;
        }
    };
    
    // submit an install order note
    $scope.submitInstallOrderNote = function() {
        // return if the install order note is invalid
        if (!$scope.activeInstallOrderNote.valid) {
            return;
        }

        // submit the install order note
        var first_mod_id, second_mod_id;
        if ($scope.activeInstallOrderNote.order === 'before') {
            first_mod_id = $scope.mod.id;
            second_mod_id = $scope.activeInstallOrderNote.mod_id;
        } else {
            first_mod_id = $scope.activeInstallOrderNote.mod_id;
            second_mod_id = $scope.mod.id;
        }
        var noteObj = {
            install_order_note: {
                game_id: $scope.mod.game_id,
                first_mod_id: first_mod_id,
                second_mod_id: second_mod_id,
                text_body: $scope.activeInstallOrderNote.text_body
            }
        };
        $scope.activeInstallOrderNote.submitting = true;
        contributionService.submitContribution("install_order_notes", noteObj).then(function(data) {
            if (data.status == "ok") {
                $scope.submitMessage = "Install Order Note submitted successfully!";
                $scope.showSuccess = true;
                // TODO: push the Install Order note onto the $scope.mod.install_order_notes array
                delete $scope.activeInstallOrderNote;
            }
        });
    };

    // LOAD ORDER NOTE RELATED LOGIC
    // instantiate a new load order note object
    $scope.startNewLoadOrderNote = function() {
        // set up activeLoadOrderNote object
        $scope.activeLoadOrderNote = {
            order: "before",
            text_body: ""
        };

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // edit an existing load order note
    $scope.editLoadOrderNote = function(load_order_note) {
        load_order_note.editing = true;
        $scope.activeLoadOrderNote = load_order_note;

        // update the markdown editor
        $scope.updateMDE = true;
        $scope.updateMDE = false;
    };

    // discard the load order note object
    $scope.discardLoadOrderNote = function() {
        if ($scope.activeLoadOrderNote.editing) {
            $scope.activeLoadOrderNote.editing = false;
            $scope.activeLoadOrderNote = null;
        } else {
            delete $scope.activeLoadOrderNote;
        }
    };

    // ANALYSIS RELATED LOGIC
    // select the plugin the user selected
    $scope.selectPlugin = function() {
        $scope.currentPlugin = $scope.mod.plugins.find(function(plugin) {
            return plugin.filename == $scope.currentPluginFilename;
        });
    };
});
