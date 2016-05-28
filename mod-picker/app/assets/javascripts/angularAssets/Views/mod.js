app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('mod', {
            templateUrl: '/resources/partials/showMod/mod.html',
            controller: 'modController',
            url: '/mod/:modId',
            redirectTo: 'mod.Reviews',
            resolve: {
                modObject: function(modService, $stateParams) {
                    return modService.retrieveMod($stateParams.modId);
                },
                modId: function($stateParams) {
                  return $stateParams.modId;
                }
            }
        }).state('mod.Reviews', {
            templateUrl: '/resources/partials/showMod/reviews.html',
            controller: 'modReviewsController',
            url: '/reviews',
            params: {
                //if reviews were retrieved and then the tab was changed, the sort from that retrieval is used
                sort: function($state) {
                  var parentState = $state.$current.parent;
                  if (parentState && parentState.lastReviewSort){
                    return parentState.lastReviewSort;
                  }
                  else {
                    return 'reputation';
                  }
                }
            },
            resolve: {
                reviews: function($stateParams, modId, modService) {
                  //only resolve if the data will be different than what is already in $scope
                  if (this.parent.lastReviewSort !== $stateParams.sort) {
                    this.parent.lastReviewSort = $stateParams.sort;
                    return modService.retrieveReviews(modId, {sort: $stateParams.sort});
                  }
              },
              reviewSections: function(modObject, reviewSectionService) {
                  return reviewSectionService.getSectionsForCategory(modObject.mod.primary_category);
              }
            }
        }).state('mod.Compatibility', {
            templateUrl: '/resources/partials/showMod/compatibility.html',
            controller: 'modCompatibilityController',
            url: '/compatibility',
            params: {
                //if notes were retrieved and then the tab was changed, the sorting from that retrieval is used
                sort: function($state) {
                  var parentState = $state.$current.parent;
                  if (parentState && parentState.lastCompatibilitySort){
                    return parentState.lastCompatibilitySort;
                  }
                  else {
                    //if this is the first retrieval default to sorting by reputation
                    return 'reputation';
                  }
                },
                filters: {
                  mod_list: true
                }
            },
            resolve: {
                compatibilityNotes: function($stateParams, modId, modService) {
                  //only resolve if the data will be different than what is already in $scope
                  if (this.parent.lastCompatibilitySort !== $stateParams.sort) {
                    this.parent.lastCompatibilitySort = $stateParams.sort;

                    options = {
                      sort: $stateParams.sort,
                      filters: $stateParams.filters
                    };
                    return modService.retrieveCompatibilityNotes(modId, options);
                  }
                }
            }
        }).state('mod.Install Order', {
            templateUrl: '/resources/partials/showMod/installOrder.html',
            controller: 'modInstallOrderController',
            url: '/install-order',
            params: {
                //if notes were retrieved and then the tab was changed, the sorting from that retrieval is used
                sort: function($state) {
                  var parentState = $state.$current.parent;
                  if (parentState && parentState.lastInstallOrderSort){
                    return parentState.lastInstallOrderSort;
                  }
                  else {
                    //if this is the first retrieval default to sorting by reputation
                    return 'reputation';
                  }
                },
                filters: {
                  mod_list: true
                }
            },
            resolve: {
                installOrderNotes: function($stateParams, modId, modService) {
                  //only resolve if the data will be different than what is already in $scope
                  if (this.parent.lastInstallOrderSort !== $stateParams.sort) {
                    this.parent.lastInstallOrderSort = $stateParams.sort;

                    options = {
                      sort: $stateParams.sort,
                      filters: $stateParams.filters
                    };
                    return modService.retrieveInstallOrderNotes(modId, options);
                  }
                }
            }
        }).state('mod.Load Order', {
            templateUrl: '/resources/partials/showMod/loadOrder.html',
            controller: 'modLoadOrderController',
            url: '/load-order',
            params: {
                //if notes were retrieved and then the tab was changed, the sorting from that retrieval is used
                sort: function($state) {
                  var parentState = $state.$current.parent;
                  if (parentState && parentState.lastLoadOrderSort){
                    return parentState.lastLoadOrderSort;
                  }
                  else {
                    //if this is the first retrieval default to sorting by reputation
                    return 'reputation';
                  }
                },
                filters: {
                  mod_list: true
                }
            },
            resolve: {
                loadOrderNotes: function($stateParams, modId, modService) {
                  //only resolve if the data will be different than what is already in $scope
                  if (this.parent.lastLoadOrderSort !== $stateParams.sort) {
                    this.parent.lastLoadOrderSort = $stateParams.sort;

                    options = {
                      sort: $stateParams.sort,
                      filters: $stateParams.filters
                    };
                    return modService.retrieveLoadOrderNotes(modId, options);
                  }
                }
            }
        }).state('mod.Analysis', {
            templateUrl: '/resources/partials/showMod/analysis.html',
            controller: 'modAnalysisController',
            url: '/analysis',
            resolve: {
                analysis: function(modId, modService) {
                    return modService.retrieveAnalysis(modId);
                }
            }
        });
}]);

app.controller('modController', function ($scope, $q, $stateParams, $timeout, modObject, modService, pluginService, categoryService, gameService, recordGroupService, userTitleService, assetUtils, reviewSectionService, userService, contributionService, contributionFactory, errorsFactory, tagService, smoothScroll){
    $scope.mod = modObject.mod;
    $scope.mod.star = modObject.star;

    $scope.tags = [];
    $scope.newTags = [];

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

    // // remove Load Order tab if mod has no plugins
    // if ($scope.mod.plugins_count == 0) {
    //     $scope.tabs.splice(3, 1);
    // }

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
        };
    };

    // update the markdown editor
    $scope.updateEditor = function() {
        $timeout(function() {
            var editorBox = document.getElementsByClassName("add-note-box")[0];
            smoothScroll(editorBox, {offset: 20});
        });
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    // HEADER RELATED LOGIC
    $scope.starMod = function() {
        modService.starMod($scope.mod.id, $scope.modStarred).then(function(data) {
            if (data.status == 'ok') {
                $scope.modStarred = $scope.modStarred ? false : true;
            }
        });
    };

    // TAG RELATED LOGIC
    $scope.saveTags = function(updatedTags) {
        var response = $q.defer();
        tagService.updateModTags($scope.mod, updatedTags).then(function(data) {
            if (data.status == "ok") {
                $scope.submitMessage = "Tags submitted successfully.";
                $scope.showSuccess = true;
            } else {
                $scope.errors = data.errors;
            }
            response.resolve(data);
        });
        return response.promise;
    };

    // ANALYSIS RELATED LOGIC

});

app.controller('modReviewsController', function ($scope, $stateParams, $state, reviews, reviewSections) {
  if(reviews) {
    $scope.mod.reviews = reviews;
  }

  $scope.reviewSort = $stateParams.sort;
  $scope.reSortReviews = function() {
    $state.go("mod.Reviews", {sort: $scope.reviewSort});
  };

  // instantiate a new review object
  $scope.startNewReview = function() {
      // set up activeReview object
      $scope.activeReview = {
          ratings: [],
          text_body: ""
      };

      // set up availableSections array
      $scope.availableSections = reviewSections;

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
          ratings: review.review_ratings.slice(0),
          overall_rating: review.overall_rating,
          original: review
      };

      // set up availableSections array
      $scope.availableSections = reviewSections.filter(function(section) {
          return $scope.activeReview.ratings.find(function(rating) {
              return rating.section == section;
          }) === undefined;
      });

      // update the markdown editor
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

  // update a review locally
  $scope.updateReview = function() {
      var originalReview = $scope.activeReview.original;
      var updatedReview = $scope.activeReview;
      // update the values on the original review
      originalReview.text_body = updatedReview.text_body.slice(0);
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
              review_ratings_attributes: review_ratings
          }
      };
      $scope.activeReview.submitting = true;

      // use update or submit contribution
      if ($scope.activeReview.original) {
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

app.controller('modCompatibilityController', function ($scope, compatibilityNotes, $stateParams, $state) {
  if(compatibilityNotes) {
    $scope.mod.compatibility_notes = compatibilityNotes;
  }

  $scope.compatibilitySort = $stateParams.sort;
    $scope.reSortCompatibility = function() {
      $state.go("mod.Compatibility", {sort: $scope.compatibilitySort});
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
        $scope.updateEditor();
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
        $scope.updateEditor();
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
});

app.controller('modInstallOrderController', function ($scope, installOrderNotes, $state, $stateParams) {
  if(installOrderNotes) {
    $scope.mod.install_order_notes = installOrderNotes;
  }

  $scope.installOrderSort = $stateParams.sort;
    $scope.reSortInstallOrder = function() {
      $state.go("mod.Install Order", {sort: $scope.installOrderSort});
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
        $scope.updateEditor();
    };

    // edit an existing install order note
    $scope.editInstallOrderNote = function(install_order_note) {
        install_order_note.editing = true;
        $scope.activeInstallOrderNote = install_order_note;

        // update the markdown editor
        $scope.updateEditor();
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
});

app.controller('modLoadOrderController', function ($scope, loadOrderNotes, $state, $stateParams) {
  if(loadOrderNotes) {
    $scope.mod.load_order_notes = loadOrderNotes;
  }

  $scope.loadOrderSort = $stateParams.sort;
    $scope.reSortLoadOrder = function() {
      $state.go("mod.Load Order", {sort: $scope.loadOrderSort});
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
        $scope.updateEditor();
    };

    // edit an existing load order note
    $scope.editLoadOrderNote = function(load_order_note) {
        load_order_note.editing = true;
        $scope.activeLoadOrderNote = load_order_note;

        // update the markdown editor
        $scope.updateEditor();
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
});

app.controller('modAnalysisController', function ($scope, analysis) {
    $scope.mod.plugins = analysis.plugins;
    $scope.mod.assets = analysis.assets;
    $scope.currentPlugin = analysis.plugins[0];
});
