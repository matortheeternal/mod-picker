app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('mod', {
            templateUrl: '/resources/partials/showMod/mod.html',
            controller: 'modController',
            url: '/mod/:modId',
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
                sort: 'reputation'
            },
            resolve: {
                reviews: function($stateParams, modId, modService) {
                    return modService.retrieveReviews(modId, {sort: $stateParams.sort});
                }
            }
        }).state('mod.Compatibility', {
            templateUrl: '/resources/partials/showMod/compatibility.html',
            controller: 'modCompatibilityController',
            url: '/compatibility',
            params: {
                sort: 'reputation'
            },
            resolve: {
                compatibilityNotes: function($stateParams, modId, modService) {
                    return modService.retrieveCompatibilityNotes(modId, {sort: $stateParams.sort});
                }
            }
        }).state('mod.Install Order', {
            templateUrl: '/resources/partials/showMod/installOrder.html',
            controller: 'modInstallOrderController',
            url: '/install-order',
            params: {
                sort: 'reputation'
            },
            resolve: {
                installOrderNotes: function($stateParams, modId, modService) {
                    return modService.retrieveInstallOrderNotes(modId, {sort: $stateParams.sort});
                }
            }
        }).state('mod.Load Order', {
            templateUrl: '/resources/partials/showMod/loadOrder.html',
            controller: 'modLoadOrderController',
            url: '/load-order',
            params: {
                sort: 'reputation'
            },
            resolve: {
                loadOrderNotes: function($stateParams, modId, modService) {
                    return modService.retrieveLoadOrderNotes(modId, {sort: $stateParams.sort});
                }
            }
        }).state('mod.Analysis', {
            templateUrl: '/resources/partials/showMod/analysis.html',
            controller: 'modAnalysisController',
            url: '/analysis'
        });
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

app.controller('modController', function ($scope, $q, $stateParams, $timeout, modObject, modService, pluginService, categoryService, gameService, recordGroupService, userTitleService, assetUtils, reviewSectionService, userService, contributionService, contributionFactory, smoothScroll){
    $scope.mod = modObject.mod;
    $scope.mod.star = modObject.star;

    $scope.tags = [];
    $scope.newTags = [];

    $scope.filters = {
        compatibility_notes: true,
        install_order_notes: true,
        load_order_notes: true
    };

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

    // getting games
    gameService.retrieveGames().then(function (data) {
        $scope.game = gameService.getGameById(data, $scope.mod.game_id);
    });

    // // remove Load Order tab if mod has no plugins
    // if ($scope.mod.plugins_count == 0) {
    //     $scope.tabs.splice(3, 1);
    // }

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

    // TAB RELATED LOGIC
    // $scope.currentTab = $scope.tabs[0];
    //
    // $scope.switchTab = function(targetTab) {
    //     switch (targetTab.name) {
    //         case 'Reviews':
    //             if ($scope.mod.reviews == null) {
    //                 $scope.retrieveReviews();
    //             }
    //             break;
    //         case 'Compatibility':
    //             if ($scope.mod.compatibility_notes == null) {
    //                 $scope.retrieveCompatibilityNotes();
    //             }
    //             break;
    //         case 'Install Order':
    //             if ($scope.mod.install_order_notes == null) {
    //                 $scope.retrieveInstallOrderNotes();
    //             }
    //             break;
    //         case 'Load Order':
    //             if ($scope.mod.load_order_notes == null) {
    //                 $scope.retrieveLoadOrderNotes();
    //             }
    //             break;
    //         case 'Analysis':
    //             if ($scope.mod.analysis == null) {
    //                 $scope.retrieveAnalysis();
    //             }
    //             break;
    //     }
    // };

    $scope.retrieveCompatibilityNotes = function() {
        var options = {
            sort: $scope.sort.compatibility_notes || 'reputation',
            filters: {
                mod_list: $scope.filters.compatibility_notes || true
            }
        };
        modService.retrieveCompatibilityNotes($stateParams.modId, options).then(function(data) {
            $scope.mod.compatibility_notes = data;
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
            $scope.mod.install_order_notes = data;
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
            $scope.mod.load_order_notes = data;
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

    // ANALYSIS RELATED LOGIC

});

app.controller('modReviewsController', function ($scope, reviews, reviewSectionService) {
  $scope.mod.reviews = reviews;

  //set review sections on mod
  $scope.mod.reviewSections = reviewSectionService.getSectionsForCategory($scope.mod.primary_category);

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
          ratings: review.review_ratings.slice(0),
          overall_rating: review.overall_rating,
          original: review
      };

      // set up availableSections array
      $scope.availableSections = $scope.reviewSections.filter(function(section) {
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

app.controller('modCompatibilityController', function ($scope, compatibilityNotes) {
  $scope.mod.compatibility_notes = compatibilityNotes;

});

app.controller('modInstallOrderController', function ($scope, installOrderNotes) {
  $scope.mod.install_order_notes = installOrderNotes;

});

app.controller('modLoadOrderController', function ($scope, loadOrderNotes) {
  $scope.mod.load_order_notes = loadOrderNotes;

});

app.controller('modAnalysisController', function ($scope) {
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
    // select the plugin the user selected
    $scope.selectPlugin = function() {
        $scope.currentPlugin = $scope.mod.plugins.find(function(plugin) {
            return plugin.filename == $scope.currentPluginFilename;
        });
    };
});
