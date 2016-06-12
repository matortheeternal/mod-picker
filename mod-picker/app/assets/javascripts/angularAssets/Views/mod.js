app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.mod', {
        templateUrl: '/resources/partials/showMod/mod.html',
        controller: 'modController',
        url: '/mod/:modId',
        redirectTo: 'base.mod.Reviews',
        resolve: {
            modObject: function(modService, $stateParams) {
                return modService.retrieveMod($stateParams.modId);
            },
            modId: function($stateParams) {
                return $stateParams.modId;
            }
        }
    }).state('base.mod.Reviews', {
        templateUrl: '/resources/partials/showMod/reviews.html',
        controller: 'modReviewsController',
        url: '/reviews',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            },
            retrieve: true,
            page: 1
        },
        resolve: {
            reviews: function($q, $state, $stateParams, modId, modObject, modService, reviewSectionService) {
                //hardcoded redirect to the analysis tab when it's the base game
                if (!modObject.mod.primary_category_id) {
                    $state.go('base.mod.Analysis', {
                        modId: modId
                    });
                }

                //only resolve if the retrieve param is true
                if ($stateParams.retrieve) {
                    var options = {
                        sort: $stateParams.sort,
                        page: $stateParams.page
                    };
                    this.self.data = { pages: {} };
                    return modService.retrieveReviews(modId, options, this.self.data.pages);
                }
            },
            reviewSections: function(modObject, reviewSectionService) {
                return reviewSectionService.getSectionsForCategory(modObject.mod.primary_category);
            }
        }
    }).state('base.mod.Compatibility', {
        templateUrl: '/resources/partials/showMod/compatibility.html',
        controller: 'modCompatibilityController',
        url: '/compatibility',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            },
            retrieve: true,
            filters: {
                mod_list: true
            },
            page: 1
        },
        resolve: {
            compatibilityNotes: function($stateParams, $state, modId, modService, modObject) {
                //hardcoded redirect to the analysis tab when it's the base game
                if (!modObject.mod.primary_category_id) {
                    $state.go('base.mod.Analysis', {
                        modId: modId
                    });
                }

                //only resolve if the retrieve param is true
                if ($stateParams.retrieve) {
                    var options = {
                        sort: $stateParams.sort,
                        filters: $stateParams.filters,
                        page: $stateParams.page
                    };
                    this.self.data = { pages: {} };
                    return modService.retrieveContributions(modId, 'compatibility_notes', options, this.self.data.pages);
                }
            }
        }
    }).state('base.mod.Install Order', {
        templateUrl: '/resources/partials/showMod/installOrder.html',
        controller: 'modInstallOrderController',
        url: '/install-order',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            },
            retrieve: true,
            filters: {
                mod_list: true
            },
            page: 1
        },
        resolve: {
            installOrderNotes: function($stateParams, $state, modId, modService, modObject) {
                //hardcoded redirect to the analysis tab when it's the base game
                if (!modObject.mod.primary_category_id) {
                    $state.go('base.mod.Analysis', {
                        modId: modId
                    });
                }

                //only resolve if the retrieve param is true
                if ($stateParams.retrieve) {
                    var options = {
                        sort: $stateParams.sort,
                        filters: $stateParams.filters,
                        page: $stateParams.page
                    };
                    this.self.data = { pages: {} };
                    return modService.retrieveContributions(modId, 'install_order_notes', options, this.self.data.pages);
                }
            }
        }
    }).state('base.mod.Load Order', {
        templateUrl: '/resources/partials/showMod/loadOrder.html',
        controller: 'modLoadOrderController',
        url: '/load-order',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            },
            retrieve: true,
            filters: {
                mod_list: true
            },
            page: 1
        },
        resolve: {
            loadOrderNotes: function($stateParams, $state, modId, modService, modObject) {
                //hardcoded redirect to the analysis tab when it's the base game
                if (!modObject.mod.primary_category_id) {
                    $state.go('base.mod.Analysis', {
                        modId: modId
                    });
                }
                //hardcoded redirect to the reviews tab when there aren't any
                if (modObject.mod.plugins_count === 0) {
                    $state.go('base.mod.Reviews', {
                        modId: modId
                    });
                }

                //only resolve if the retrieve param is true
                if ($stateParams.retrieve) {
                    var options = {
                        sort: $stateParams.sort,
                        filters: $stateParams.filters,
                        page: $stateParams.page
                    };
                    this.self.data = { pages: {} };
                    return modService.retrieveContributions(modId, 'load_order_notes', options, this.self.data.pages);
                }
            }
        }
    }).state('base.mod.Analysis', {
        templateUrl: '/resources/partials/showMod/analysis.html',
        controller: 'modAnalysisController',
        url: '/analysis',
        params: {
            retrieve: true
        },
        resolve: {
            analysis: function($stateParams, modObject, modService) {
                //only resolve if the retrieve param is true
                if ($stateParams.retrieve) {
                    return modService.retrieveAnalysis(modObject.mod.id, modObject.mod.game_id);
                }
            }
        }
    });
}]);

app.controller('modController', function($scope, $q, $stateParams, $timeout, currentUser, modObject, modService, pluginService, categoryService, gameService, recordGroupService, userTitleService, assetUtils, reviewSectionService, userService, contributionService, contributionFactory, errorsFactory, tagService, smoothScroll) {
    // get parent variables
    $scope.mod = modObject.mod;
    $scope.mod.star = modObject.star;
    $scope.currentUser = currentUser;

    $scope.tags = [];
    $scope.newTags = [];
    $scope.statusModal = {};
    $scope.pages = {};
    $scope.retrieving = {};

    //a copy is created so the original permissions are never changed
    $scope.permissions = angular.copy(currentUser.permissions);
    //setting up the canManage permission
    var author = $scope.mod.author_users.find(function(author) {
        return author.id == $scope.currentUser.id;
    });
    var isAuthor = author !== null;
    $scope.permissions.canManage = $scope.permissions.canModerate || isAuthor;

    //tabs array
    $scope.tabs = [{
        name: 'Reviews',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            }
        }
    }, {
        name: 'Compatibility',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            }
        }
    }, {
        name: 'Install Order',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            }
        }
    }, {
        name: 'Load Order',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            }
        }
    }, {
        name: 'Analysis',
        params: {}
    }];

    //returns a reference to the tab with tabName (because sometimes tabs are removed)
    $scope.findTab = function(tabName) {
        var index = $scope.tabs.findIndex(function(tab) {
            return tab.name === tabName;
        });
        return $scope.tabs[index];
    };

    //removes the tab with tabName
    $scope.removeTab = function(tabName) {
        var index = $scope.tabs.findIndex(function(tab) {
            return tab.name === tabName;
        });
        delete $scope.tabs[index];
    };

    // only display analysis tab if mod doesn't have a primary category
    if (!$scope.mod.primary_category_id) {
        $scope.removeTab('Reviews');
        $scope.removeTab('Compatibility');
        $scope.removeTab('Install Order');
        $scope.removeTab('Load Order');
    }
    // remove Load Order tab if mod has no plugins
    else if ($scope.mod.plugins_count === 0) {
        $scope.removeTab('Load Order');
    }

    //set the class of the status box
    switch ($scope.mod.status) {
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

    // change sort direction
    $scope.toggleSortDirection = function(sort) {
        sort.direction = sort.direction === 'asc' ? 'desc' : 'asc';
    };

    // update the markdown editor
    $scope.updateEditor = function(noScroll) {
        if (!noScroll) {
            $timeout(function() {
                var editorBox = document.getElementsByClassName("add-note-box")[0];
                smoothScroll(editorBox, {
                    offset: 20
                });
            });
        }
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    $scope.retrieveCorrections = function() {
        $scope.retrieving.corrections = true;
        modService.retrieveCorrections($stateParams.modId).then(function(corrections) {
            $scope.mod.corrections = corrections;
            $scope.getAppealStatus();
        });
    };

    // HEADER RELATED LOGIC
    $scope.starMod = function() {
        modService.starMod($scope.mod.id, $scope.mod.star).then(function(data) {
            if (data.status == 'ok') {
                $scope.star = !$scope.star;
            }
        });
    };

    $scope.toggleStatusModal = function(visible) {
        $scope.statusModal.visible = visible;
        if (!$scope.mod.corrections && !$scope.retrieving.corrections) {
            $scope.retrieveCorrections();
        }
    };

    $scope.getAppealStatus = function() {
        var openAppeals = $scope.mod.corrections.filter(function(correction) {
            return !correction.hidden && (correction.status == "open");
        });
        $scope.appealStatus = $scope.permissions.canAppeal && openAppeals.length < 2;
    };

    $scope.saveTags = function(updatedTags) {
        var response = $q.defer();
        tagService.updateModTags($scope.mod, updatedTags).then(function(data) {
            if (data.status === "ok") {
                $scope.submitMessage = "Tags submitted successfully.";
                $scope.showSuccess = true;
            } else {
                $scope.errors = data.errors;
            }
            response.resolve(data);
        });
        return response.promise;
    };
});


app.controller('modReviewsController', function($scope, $stateParams, $state, reviews, reviewSections, contributionService) {
    if (reviews) {
        $scope.mod.reviews = reviews;
        $scope.pages.reviews = $state.current.data.pages;
    }

    $scope.currentTab = $scope.findTab('Reviews');
    $scope.currentParams = $scope.currentTab.params;
    $scope.currentParams.retrieve = false;

    $scope.reSortReviews = function() {
        $state.go("base.mod.Reviews", {
            sort: $scope.currentParams.sort,
            retrieve: true
        });
    };

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
        reviewSections.forEach(function(section) {
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
        $scope.availableSections = reviewSections.filter(function(section) {
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
            contributionService.updateContribution("reviews", reviewId, reviewObj).then(function(data) {
                if (data.status == "ok") {
                    $scope.submitMessage = "Review updated successfully!";
                    $scope.showSuccess = true;

                    // update original review object and discard copy
                    $scope.updateReview();
                    $scope.discardReview();
                }
            });
        } else {
            contributionService.submitContribution("reviews", reviewObj).then(function(data) {
                if (data.status == "ok") {
                    $scope.submitMessage = "Review submitted successfully!";
                    $scope.showSuccess = true;
                    // TODO: push the review onto the $scope.mod.reviews array
                    $scope.discardReview();
                }
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

app.controller('modCompatibilityController', function($scope, $stateParams, compatibilityNotes, $state, contributionFactory, contributionService) {
    if (compatibilityNotes) {
        $scope.mod.compatibility_notes = compatibilityNotes;
        $scope.pages.compatibility_notes = $state.current.data.pages;
    }

    $scope.currentTab = $scope.findTab('Compatibility');
    $scope.currentParams = $scope.currentTab.params;
    $scope.currentParams.retrieve = false;

    $scope.reSortCompatibility = function() {
        $state.go("base.mod.Compatibility", {
            sort: $scope.currentParams.sort,
            retrieve: true
        });
    };

    // COMPATIBILITY NOTE RELATED LOGIC
    // instantiate a new compatibility note object
    $scope.startNewCompatibilityNote = function() {
        // set up activeCompatibilityNote object
        $scope.activeCompatibilityNote = {
            status: "incompatible",
            text_body: contributionFactory.getDefaultTextBody("CompatibilityNote")
        };

        // update the markdown editor
        $scope.updateEditor();
    };

    // edit an existing compatibility note
    $scope.editCompatibilityNote = function(compatibility_note) {
        compatibility_note.editing = true;
        var secondMod = compatibility_note.mods.find(function(mod) {
            return mod.id !== $scope.mod.id;
        });
        $scope.activeCompatibilityNote = {
            status: compatibility_note.status,
            mod_id: secondMod.id,
            mod_name: secondMod.name,
            compatibility_mod_id: compatibility_note.compatibility_mod_id,
            compatibility_plugin_id: compatibility_note.compatibility_plugin_id,
            text_body: compatibility_note.text_body.slice(0),
            moderator_message: compatibility_note.moderator_message && compatibility_note.moderator_message.slice(0),
            original: compatibility_note,
            editing: true
        };

        // update validation, update the markdown editor
        $scope.validateCompatibilityNote();
        $scope.updateEditor();
    };

    $scope.validateCompatibilityNote = function() {
        // exit if we don't have a activeCompatibilityNote yet
        if (!$scope.activeCompatibilityNote) {
            return;
        }

        $scope.activeCompatibilityNote.valid = $scope.activeCompatibilityNote.text_body.length > 512 &&
            ($scope.activeCompatibilityNote.mod_id !== undefined) &&
            ($scope.activeCompatibilityNote.status === "compatibility mod") ==
            ($scope.activeCompatibilityNote.compatibility_mod !== undefined);
    };

    // discard the compatibility note object
    $scope.discardCompatibilityNote = function() {
        if ($scope.activeCompatibilityNote.editing) {
            $scope.activeCompatibilityNote.original.editing = false;
            $scope.activeCompatibilityNote = null;
        } else {
            delete $scope.activeCompatibilityNote;
        }
    };

    // update a compatibility note locally
    $scope.updateCompatibilityNote = function(updatedNote) {
        var originalNote = $scope.activeCompatibilityNote.original;
        // update the values on the original note
        originalNote.text_body = updatedNote.text_body.slice(0);
        originalNote.moderator_message = updatedNote.moderator_message && updatedNote.moderator_message.slice(0);
        originalNote.status = updatedNote.status;
    };

    // save a compatibility note
    $scope.saveCompatibilityNote = function() {
        // return if the compatibility note is invalid
        if (!$scope.activeCompatibilityNote.valid) {
            return;
        }

        // submit the compatibility note
        var noteObj = {
            compatibility_note: {
                game_id: $scope.mod.game_id,
                status: $scope.activeCompatibilityNote.status,
                first_mod_id: $scope.mod.id,
                second_mod_id: $scope.activeCompatibilityNote.mod_id,
                text_body: $scope.activeCompatibilityNote.text_body,
                edit_summary: $scope.activeCompatibilityNote.edit_summary,
                moderator_message: $scope.activeCompatibilityNote.moderator_message,
                compatibility_plugin_id: $scope.activeCompatibilityNote.compatibility_plugin_id,
                compatibility_mod_id: $scope.activeCompatibilityNote.compatibility_mod_id
            }
        };
        $scope.activeCompatibilityNote.submitting = true;

        // use update or submit contribution
        if ($scope.activeCompatibilityNote.editing) {
            var noteId = $scope.activeCompatibilityNote.original.id;
            contributionService.updateContribution("compatibility_notes", noteId, noteObj).then(function(data) {
                if (data.status === "ok") {
                    $scope.submitMessage = "Compatibility Note updated successfully!";
                    $scope.showSuccess = true;

                    // update original compatibility note and discard copy
                    $scope.updateCompatibilityNote(noteObj.compatibility_note);
                    $scope.discardCompatibilityNote();
                }
            });
        } else {
            contributionService.submitContribution("compatibility_notes", noteObj).then(function(data) {
                if (data.status === "ok") {
                    $scope.submitMessage = "Compatibility Note submitted successfully!";
                    $scope.showSuccess = true;
                    // TODO: push the compatibility note onto the $scope.mod.compatibility_notes array
                    $scope.discardCompatibilityNote();
                }
            });
        }
    };
});

app.controller('modInstallOrderController', function($scope, $stateParams, installOrderNotes, $state, contributionService) {
    if (installOrderNotes) {
        $scope.mod.install_order_notes = installOrderNotes;
        $scope.pages.install_order_notes = $state.current.data.pages;
    }

    $scope.currentTab = $scope.findTab('Install Order');
    $scope.currentParams = $scope.currentTab.params;
    $scope.currentParams.retrieve = false;

    $scope.reSortInstallOrder = function() {
        $state.go("base.mod.Install Order", {
            sort: $scope.currentParams.sort,
            retrieve: true
        });
    };

    // INSTALL ORDER NOTE RELATED LOGIC
    // instantiate a new install order note object
    $scope.startNewInstallOrderNote = function() {
        // set up activeInstallOrderNote object
        $scope.activeInstallOrderNote = {
            order: "before",
            text_body: contributionFactory.getDefaultTextBody("InstallOrderNote")
        };

        // update the markdown editor
        $scope.updateEditor();
    };

    // edit an existing install order note
    $scope.editInstallOrderNote = function(install_order_note) {
        install_order_note.editing = true;
        var mod_id, order;
        for (var i = 0; i < 2; i++) {
            if (install_order_note.mods[i].id != $scope.mod.id) {
                mod_id = install_order_note.mods[i].id.toString();
                order = i == 0 ? 'after' : 'before';
            }
        }
        $scope.activeInstallOrderNote = {
            mod_id: mod_id,
            order: order,
            text_body: install_order_note.text_body.slice(0),
            moderator_message: install_order_note.moderator_message && install_order_note.moderator_message.slice(0),
            original: install_order_note,
            editing: true
        };

        // update validation, update the markdown editor
        $scope.validateInstallOrderNote();
        $scope.updateEditor();
    };

    $scope.validateInstallOrderNote = function() {
        // exit if we don't have a activeInstallOrderNote yet
        if (!$scope.activeInstallOrderNote) {
            return;
        }

        $scope.activeInstallOrderNote.valid = $scope.activeInstallOrderNote.text_body.length > 256 &&
            ($scope.activeInstallOrderNote.mod_id !== undefined);
    };

    // discard the install order note object
    $scope.discardInstallOrderNote = function() {
        if ($scope.activeInstallOrderNote.editing) {
            $scope.activeInstallOrderNote.original.editing = false;
            $scope.activeInstallOrderNote = null;
        } else {
            delete $scope.activeInstallOrderNote;
        }
    };

    // update an install order note locally
    $scope.updateInstallOrderNote = function(updatedNote) {
        var originalNote = $scope.activeInstallOrderNote.original;
        // update the values on the original note
        if ((updatedNote.first_mod_id == originalNote.second_mod_id) &&
            (updatedNote.second_mod_id == originalNote.first_mod_id)) {
            originalNote.mods.reverse();
            originalNote.first_mod_id = originalNote.mods[0].id;
            originalNote.second_mod_id = originalNote.mods[1].id;
        }
        originalNote.text_body = updatedNote.text_body.slice(0);
        originalNote.moderator_message = updatedNote.moderator_message && updatedNote.moderator_message.slice(0);
    };

    // submit an install order note
    $scope.saveInstallOrderNote = function() {
        // return if the install order note is invalid
        if (!$scope.activeInstallOrderNote.valid) {
            return;
        }

        // submit the install order note
        var first_mod_id, second_mod_id;
        if ($scope.activeInstallOrderNote.order === 'before') {
            first_mod_id = $scope.mod.id;
            second_mod_id = parseInt($scope.activeInstallOrderNote.mod_id);
        } else {
            first_mod_id = parseInt($scope.activeInstallOrderNote.mod_id);
            second_mod_id = $scope.mod.id;
        }
        var noteObj = {
            install_order_note: {
                game_id: $scope.mod.game_id,
                first_mod_id: first_mod_id,
                second_mod_id: second_mod_id,
                text_body: $scope.activeInstallOrderNote.text_body,
                edit_summary: $scope.activeInstallOrderNote.edit_summary,
                moderator_message: $scope.activeInstallOrderNote.moderator_message
            }
        };
        $scope.activeInstallOrderNote.submitting = true;

        // use update or submit contribution
        if ($scope.activeInstallOrderNote.editing) {
            var noteId = $scope.activeInstallOrderNote.original.id;
            contributionService.updateContribution("install_order_notes", noteId, noteObj).then(function(data) {
                if (data.status === "ok") {
                    $scope.submitMessage = "Install Order Note updated successfully!";
                    $scope.showSuccess = true;

                    // update original install order note and discard copy
                    $scope.updateInstallOrderNote(noteObj.install_order_note);
                    $scope.discardInstallOrderNote();
                }
            });
        } else {
            contributionService.submitContribution("install_order_notes", noteObj).then(function(data) {
                if (data.status === "ok") {
                    $scope.submitMessage = "Install Order Note submitted successfully!";
                    $scope.showSuccess = true;
                    // TODO: push the Install Order note onto the $scope.mod.install_order_notes array
                    $scope.discardInstallOrderNote();
                }
            });
        }
    };
});

app.controller('modLoadOrderController', function($scope, $state, $stateParams, loadOrderNotes, contributionService) {
    if (loadOrderNotes) {
        $scope.mod.load_order_notes = loadOrderNotes;
        $scope.pages.load_order_notes = $state.current.data.pages;
    }

    $scope.currentTab = $scope.findTab('Load Order');
    $scope.currentParams = $scope.currentTab.params;
    $scope.currentParams.retrieve = false;

    $scope.reSortLoadOrder = function() {
        $state.go("base.mod.Load Order", {
            sort: $scope.currentParams.sort,
            retrieve: true
        });
    };

    // LOAD ORDER NOTE RELATED LOGIC
    // instantiate a new load order note object
    $scope.startNewLoadOrderNote = function() {
        // set up activeLoadOrderNote object
        $scope.activeLoadOrderNote = {
            first_plugin_id: $scope.mod.plugins[0].id.toString(),
            order: "before",
            text_body: contributionFactory.getDefaultTextBody("LoadOrderNote")
        };

        // update the markdown editor
        $scope.updateEditor();
    };

    // edit an existing load order note
    $scope.editLoadOrderNote = function(load_order_note) {
        load_order_note.editing = true;
        $scope.activeLoadOrderNote = load_order_note;

        // update the markdown editor
        $scope.updateEditor();
        load_order_note.editing = true;
        var order, searchText;
        for (var i = 0; i < 2; i++) {
            if (load_order_note.mods[i].id != $scope.mod.id) {
                order = i == 0 ? 'after' : 'before';
                searchText = load_order_note.plugins[i].filename;
            }
        }
        $scope.activeLoadOrderNote = {
            first_plugin_id: load_order_note.first_plugin_id.toString(),
            second_plugin_id: load_order_note.second_plugin_id.toString(),
            order: order,
            searchText: searchText,
            text_body: load_order_note.text_body.slice(0),
            moderator_message: load_order_note.moderator_message && load_order_note.moderator_message.slice(0),
            original: load_order_note,
            editing: true
        };

        // update validation, update the markdown editor
        $scope.validateLoadOrderNote();
        $scope.updateEditor();
    };

    $scope.validateLoadOrderNote = function() {
        // exit if we don't have a activeLoadOrderNote yet
        if (!$scope.activeLoadOrderNote) {
            return;
        }

        $scope.activeLoadOrderNote.valid = $scope.activeLoadOrderNote.text_body.length > 256 &&
            ($scope.activeLoadOrderNote.first_plugin_id !== undefined) &&
            ($scope.activeLoadOrderNote.second_plugin_id !== undefined);
    };

    // discard the load order note object
    $scope.discardLoadOrderNote = function() {
        if ($scope.activeLoadOrderNote.editing) {
            $scope.activeLoadOrderNote.original.editing = false;
            $scope.activeLoadOrderNote = null;
        } else {
            delete $scope.activeLoadOrderNote;
        }
    };

    // update a load order note locally
    $scope.updateLoadOrderNote = function(updatedNote) {
        var originalNote = $scope.activeLoadOrderNote.original;
        // update the values on the original note
        if ((originalNote.first_plugin_id == updatedNote.second_plugin_id) &&
            (originalNote.second_plugin_id == updatedNote.first_plugin_id)) {
            originalNote.mods.reverse();
            originalNote.plugins.reverse();
            originalNote.first_plugin_id = originalNote.plugins[0].id;
            originalNote.second_plugin_id = originalNote.plugins[1].id;
        }
        originalNote.text_body = updatedNote.text_body.slice(0);
        originalNote.moderator_message = updatedNote.moderator_message && updatedNote.moderator_message.slice(0);
    };

    // submit a load order note
    $scope.saveLoadOrderNote = function() {
        // return if the load order note is invalid
        if (!$scope.activeLoadOrderNote.valid) {
            return;
        }

        // submit the install order note
        var first_plugin_id, second_plugin_id;
        if ($scope.activeLoadOrderNote.order === 'before') {
            first_plugin_id = parseInt($scope.activeLoadOrderNote.first_plugin_id);
            second_plugin_id = parseInt($scope.activeLoadOrderNote.second_plugin_id);
        } else {
            first_plugin_id = parseInt($scope.activeLoadOrderNote.second_plugin_id);
            second_plugin_id = parseInt($scope.activeLoadOrderNote.first_plugin_id);
        }
        var noteObj = {
            load_order_note: {
                game_id: $scope.mod.game_id,
                first_plugin_id: first_plugin_id,
                second_plugin_id: second_plugin_id,
                text_body: $scope.activeLoadOrderNote.text_body,
                edit_summary: $scope.activeLoadOrderNote.edit_summary,
                moderator_message: $scope.activeLoadOrderNote.moderator_message
            }
        };
        $scope.activeLoadOrderNote.submitting = true;

        // use update or submit contribution
        if ($scope.activeLoadOrderNote.editing) {
            var noteId = $scope.activeLoadOrderNote.original.id;
            contributionService.updateContribution("load_order_notes", noteId, noteObj).then(function(data) {
                if (data.status === "ok") {
                    $scope.submitMessage = "Load Order Note updated successfully!";
                    $scope.showSuccess = true;

                    // update original load order note and discard copy
                    $scope.updateLoadOrderNote(noteObj.load_order_note);
                    $scope.discardLoadOrderNote();
                }
            });
        } else {
            contributionService.submitContribution("load_order_notes", noteObj).then(function(data) {
                if (data.status === "ok") {
                    $scope.submitMessage = "Load Order Note submitted successfully!";
                    $scope.showSuccess = true;
                    // TODO: push the Load Order note onto the $scope.mod.load_order_notes array
                    $scope.discardLoadOrderNote();
                }
            });
        }
    };
});

app.controller('modAnalysisController', function($scope, $stateParams, analysis) {
    if (analysis) {
        $scope.mod.plugins = analysis.plugins;
        $scope.mod.assets = analysis.assets;
        $scope.mod.nestedAssets = analysis.nestedAssets;
        $scope.mod.currentPlugin = analysis.plugins[0];
    }

    $scope.currentTab = $scope.findTab('Analysis');
    $scope.currentParams = $scope.currentTab.params;
    $scope.currentParams.retrieve = false;
});