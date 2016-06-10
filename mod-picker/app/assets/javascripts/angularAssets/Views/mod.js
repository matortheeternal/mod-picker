app.config(['$stateProvider', function ($stateProvider) {
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
                sort: 'reputation',
                retrieve: true
            },
            resolve: {
                reviews: function($q, $state, $stateParams, modId, modObject, modService, reviewSectionService) {
                    //hardcoded redirect to the analysis tab when it's the base game
                    if (!modObject.mod.primary_category_id) {
                        $state.go('base.mod.Analysis', {modId: modId});
                    }

                    //only resolve if the retrieve param is true
                    if ($stateParams.retrieve) {
                        return modService.retrieveReviews(modId, {sort: $stateParams.sort});
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
                sort: 'reputation',
                retrieve: true,
                filters: {
                    mod_list: true
                }
            },
            resolve: {
                compatibilityNotes: function($stateParams, $state, modId, modService, modObject) {
                    //hardcoded redirect to the analysis tab when it's the base game
                    if (!modObject.mod.primary_category_id) {
                        $state.go('base.mod.Analysis', {modId: modId});
                    }

                    //only resolve if the retrieve param is true
                    if ($stateParams.retrieve) {
                        options = {
                            sort: $stateParams.sort,
                            filters: $stateParams.filters
                        };
                        return modService.retrieveContributions(modId, 'compatibility_notes', options);
                    }
                }
            }
        }).state('base.mod.Install Order', {
            templateUrl: '/resources/partials/showMod/installOrder.html',
            controller: 'modInstallOrderController',
            url: '/install-order',
            params: {
                sort: 'reputation',
                retrieve: true,
                filters: {
                    mod_list: true
                }
            },
            resolve: {
                installOrderNotes: function($stateParams, $state, modId, modService, modObject) {
                    //hardcoded redirect to the analysis tab when it's the base game
                    if (!modObject.mod.primary_category_id) {
                        $state.go('base.mod.Analysis', {modId: modId});
                    }

                    //only resolve if the retrieve param is true
                    if ($stateParams.retrieve) {
                        options = {
                            sort: $stateParams.sort,
                            filters: $stateParams.filters
                        };
                        return modService.retrieveContributions(modId, 'install_order_notes', options);
                    }
                }
            }
        }).state('base.mod.Load Order', {
            templateUrl: '/resources/partials/showMod/loadOrder.html',
            controller: 'modLoadOrderController',
            url: '/load-order',
            params: {
                sort: 'reputation',
                retrieve: true,
                filters: {
                    mod_list: true
                }
            },
            resolve: {
                loadOrderNotes: function($stateParams, $state, modId, modService, modObject) {
                    //hardcoded redirect to the analysis tab when it's the base game
                    if (!modObject.mod.primary_category_id) {
                        $state.go('base.mod.Analysis', {modId: modId});
                    }
                    //hardcoded redirect to the reviews tab when there aren't any
                    if (modObject.mod.plugins_count === 0) {
                        $state.go('base.mod.Reviews', {modId: modId});
                    }

                    //only resolve if the retrieve param is true
                    if ($stateParams.retrieve) {
                        options = {
                            sort: $stateParams.sort,
                            filters: $stateParams.filters
                        };
                        return modService.retrieveContributions(modId, 'load_order_notes', options);
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

app.controller('modController', function ($scope, $q, $stateParams, $timeout, currentUser, modObject, modService, pluginService, categoryService, gameService, recordGroupService, userTitleService, assetUtils, reviewSectionService, userService, contributionService, contributionFactory, errorsFactory, tagService, smoothScroll){
    $scope.mod = modObject.mod;
    $scope.mod.star = modObject.star;
    $scope.user = currentUser;

    $scope.permissions = currentUser.permissions;
    //setting up the canManage permission
    var author = $scope.mod.author_users.find(function(author) {
        return author.id == $scope.user.id;
    });
    var isAuthor = author !== null;
    $scope.permissions.canManage = $scope.permissions.canModerate || isAuthor

    $scope.tags = [];
    $scope.newTags = [];

    //tabs array
    $scope.tabs = [
        { name: 'Reviews', params: {sort: 'reputation'} },
        { name: 'Compatibility', params: {sort: 'reputation'} },
        { name: 'Install Order', params: {sort: 'reputation'} },
        { name: 'Load Order', params: {sort: 'reputation'} },
        { name: 'Analysis', params: {}}
    ];

    //returns the index of the tab with tabName (because sometimes tabs are removed)
    $scope.findTab = function(tabName) {
      var index = $scope.tabs.findIndex(function(tab) {
        return tab.name === tabName;
      });
      return $scope.tabs[index];
    };

    // only display analysis tab if mod doesn't have a primary category
    if (!$scope.mod.primary_category_id) {
        $scope.tabs.splice(0,4);
    }
    // remove Load Order tab if mod has no plugins
    else if ($scope.mod.plugins_count === 0) {
        $scope.tabs.splice(3, 1);
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


    // update the markdown editor
    $scope.updateEditor = function() {
        $timeout(function() {
            var editorBox = document.getElementsByClassName("add-note-box")[0];
            smoothScroll(editorBox, {offset: 20});
        });
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    $scope.retrieveCorrections = function() {
        $scope.retrieving.corrections = true;
        modService.retrieveContributions($stateParams.modId, 'corrections').then(function(data) {
            contributionService.associateAgreementMarks(data.corrections, data.agreement_marks);
            userTitleService.associateTitles(data.corrections, $scope.userTitles);
            $scope.mod.corrections = data.corrections;
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
        $scope.showStatusModal = visible;
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
});

app.controller('modReviewsController', function ($scope, $stateParams, $state, reviews, reviewSections) {
  if(reviews) {
    $scope.mod.reviews = reviews;
  }

  $scope.findTab('Reviews').params.retrieve = false;

  $scope.reSortReviews = function() {
    $state.go("base.mod.Reviews", {sort: $scope.findTab('Reviews').params.sort, retrieve: true});
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

app.controller('modCompatibilityController', function ($scope, $stateParams, compatibilityNotes, $state, contributionFactory) {
    if(compatibilityNotes) {
    $scope.mod.compatibility_notes = compatibilityNotes;
    }

    $scope.findTab('Compatibility').params.retrieve = false;

    $scope.reSortCompatibility = function() {
      $state.go("base.mod.Compatibility", {sort: $scope.findTab('Compatibility').params.sort, retrieve: true});
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
            ($scope.activeCompatibilityNote.mod_id !== undefined) &&
            ($scope.activeCompatibilityNote.status === "compatibility mod") ==
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

    // update a compatibility note locally
    $scope.updateCompatibilityNote = function() {
        var originalNote = $scope.activeCompatibilityNote.original;
        var updatedNote = $scope.activeCompatibilityNote;
        // update the values on the original note
        originalNote.text_body = updatedNote.text_body.slice(0);
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
                compatibility_plugin_id: $scope.activeCompatibilityNote.compatibility_plugin_id,
                compatibility_mod_id: $scope.activeCompatibilityNote.compatibility_mod_id
            }
        };
        $scope.activeCompatibilityNote.submitting = true;

        // use update or submit contribution
        if ($scope.activeCompatibilityNote.original) {
            var noteId = $scope.activeCompatibilityNote.original.id;
            contributionService.updateContribution("compatibility_notes", noteId, noteObj).then(function(data) {
                if (data.status == "ok") {
                    $scope.submitMessage = "Compatibility Note updated successfully!";
                    $scope.showSuccess = true;

                    // update original review object and discard copy
                    $scope.updateCompatibilityNote();
                    $scope.discardCompatibilityNote();
                }
            });
        } else {
            contributionService.submitContribution("compatibility_notes", noteObj).then(function(data) {
                if (data.status == "ok") {
                    $scope.submitMessage = "Compatibility Note submitted successfully!";
                    $scope.showSuccess = true;
                    // TODO: push the compatibility note onto the $scope.mod.compatibility_notes array
                    $scope.discardCompatibilityNote();
                }
            });
        }
    };
});

app.controller('modInstallOrderController', function ($scope, $stateParams, installOrderNotes, $state) {
  if(installOrderNotes) {
    $scope.mod.install_order_notes = installOrderNotes;
  }

  $scope.findTab('Install Order').params.retrieve = false;

    $scope.reSortInstallOrder = function() {
      $state.go("base.mod.Install Order", {sort: $scope.findTab('Install Order').params.sort, retrieve: true});
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
        $scope.activeInstallOrderNote = install_order_note;

        // update the markdown editor
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

app.controller('modLoadOrderController', function ($scope, $stateParams, loadOrderNotes, $state) {
  if(loadOrderNotes) {
    $scope.mod.load_order_notes = loadOrderNotes;
  }

  $scope.findTab('Load Order').params.retrieve = false;

    $scope.reSortLoadOrder = function() {
      $state.go("base.mod.Load Order", {sort: $scope.findTab('Load Order').params.sort, retrieve: true});
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
            $scope.activeLoadOrderNote.editing = false;
            $scope.activeLoadOrderNote = null;
        } else {
            delete $scope.activeLoadOrderNote;
        }
    };
});

app.controller('modAnalysisController', function ($scope, $stateParams, analysis) {
    if (analysis) {
      $scope.mod.plugins = analysis.plugins;
      $scope.mod.assets = analysis.assets;
      $scope.mod.currentPlugin = analysis.plugins[0];
    }

    $scope.findTab('Analysis').params.retrieve = false;
});
