app.controller('modCompatibilityController', function($scope, $stateParams, $state, contributionFactory, contributionService) {
    // verify we can access this tab
    $scope.currentTab = $scope.findTab('Compatibility');
    if (!$scope.currentTab) {
        // if we can't access this tab, redirect to the first tab we can access and
        // stop doing stuff in this controller
        $state.go('base.mod.' + $scope.tabs[0].name, {
            modId: $stateParams.modId
        });
        return;
    }

    // BASE RETRIEVAL LOGIC
    $scope.retrieveCompatibilityNotes = function(page) {
        $scope.retrieving.compatibility_notes = true;

        // transition to new url state
        var params = {
            modId: $stateParams.modId,
            page: page,
            scol: $scope.sort.compatibility_notes.column,
            sdir: $scope.sort.compatibility_notes.direction
        };
        $state.transitionTo('base.mod.Compatibility', params, { notify: false });

        // retrieve the compatibility notes
        var options = {
            sort: $scope.sort.compatibility_notes,
            filters: $scope.filters.compatibility_notes,
            page: page || 1
        };
        contributionService.retrieveModContributions($stateParams.modId, 'compatibility_notes', options, $scope.pages.compatibility_notes).then(function(data) {
            $scope.retrieving.compatibility_notes = false;
            $scope.mod.compatibility_notes = data;
        }, function(response) {
            $scope.errors.compatibility_notes = response;
        });
    };

    // retrieve compatibility notes if we don't have them and aren't currently retrieving them
    if (!$scope.mod.compatibility_notes && !$scope.retrieving.compatibility_notes) {
        $scope.sort.compatibility_notes.column = $stateParams.scol;
        $scope.sort.compatibility_notes.direction = $stateParams.sdir;
        $scope.retrieveCompatibilityNotes($stateParams.page);
    }

    // re-retrieve compatibility note when the sort object changes
    $scope.$watch('sort.compatibility_notes', function() {
        $scope.retrieveCompatibilityNotes();
    }, true);

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
            contributionService.updateContribution("compatibility_notes", noteId, noteObj).then(function() {
                $scope.$emit("successMessage", "Compatibility Note updated successfully.");
                // update original compatibility note and discard copy
                $scope.updateCompatibilityNote(noteObj.compatibility_note);
                $scope.discardCompatibilityNote();
            }, function(response) {
                var params = {label: 'Error updating Compatibility Note', response: response};
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("compatibility_notes", noteObj).then(function(note) {
                $scope.$emit("successMessage", "Compatibility Note submitted successfully.");
                $scope.mod.reviews.unshift(note);
                $scope.discardCompatibilityNote();
            }, function(response) {
                var params = {label: 'Error submitting Compatibility Note', response: response};
                $scope.$emit('errorMessage', params);
            });
        }
    };
});