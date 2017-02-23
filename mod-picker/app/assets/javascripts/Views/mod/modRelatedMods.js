app.controller('modRelatedModsController', function($scope, $stateParams, $state, modService, contributionFactory, contributionService) {
    $scope.sort.related_mod_notes = {
        column: $stateParams.scol,
        direction: $stateParams.sdir
    };
    $scope.pages.related_mod_notes.current = $stateParams.page || 1;

    // inherited functions
    $scope.searchMods = modService.searchMods;

    // functions
    $scope.retrieveRelatedModNotes = function(page) {
        // retrieve the related mod notes
        var options = {
            sort: $scope.sort.related_mod_notes,
            page: page || $scope.pages.related_mod_notes.current
        };
        modService.retrieveModContributions($stateParams.modId, 'related_mod_notes', options, $scope.pages.related_mod_notes).then(function(data) {
            $scope.mod.related_mod_notes = data;
            if ($scope.errors.related_mod_notes) delete $scope.errors.related_mod_notes;

            // separating the related mod note in the url if any
            if ($stateParams.relatedModNoteId) {
                var currentIndex = $scope.mod.related_mod_notes.findIndex(function(relatedmodNote) {
                    return relatedmodNote.id === $stateParams.relatedModNoteId;
                });
                if (currentIndex > -1) {
                    $scope.currentRelatedModNote = $scope.mod.related_mod_notes.splice(currentIndex, 1)[0];
                } else {
                    // remove the relatedModNoteId param from the url if it's not part of this mod
                    $state.go($state.current.name, {relatedModNoteId: null});
                }
            } else {
                // clear the currentCompatibilityNote if it's not specified
                delete $scope.currentRelatedModNote;
            }
        }, function(response) {
            $scope.errors.related_mod_notes = response;
        });

        //refresh the tab's params
        var params = {
            scol: $scope.sort.related_mod_notes.column,
            sdir: $scope.sort.related_mod_notes.direction,
            page: page || 1
        };
        $state.go($state.current.name, params);
    };

    // re-retrieve related mod notes when the sort object changes
    // this will be called once automatically when the tab loads when we
    // build the sort object at line 2 in this controller
    $scope.$watch('sort.related_mod_notes', function() {
        $scope.retrieveRelatedModNotes();
    }, true);

    // RELATED MOD NOTE RELATED LOGIC
    // instantiate a new related mod note object
    $scope.startNewRelatedModNote = function() {
        // set up activeRelatedModNote object
        $scope.activeRelatedModNote = {
            status: "recommended_mod",
            text_body: contributionFactory.getDefaultTextBody("RelatedModNote")
        };

        // update the markdown editor
        $scope.updateEditor();
    };

    // edit an existing related mod note
    $scope.editRelatedModNote = function(related_mod_note) {
        related_mod_note.editing = true;
        var secondMod;
        if (related_mod_note.first_mod.id != $scope.mod.id) {
            secondMod = related_mod_note.first_mod;
        } else {
            secondMod = related_mod_note.second_mod;
        }
        $scope.activeRelatedModNote = {
            status: related_mod_note.status,
            mod_id: secondMod.id,
            mod_name: secondMod.name,
            text_body: related_mod_note.text_body.slice(0),
            moderator_message: related_mod_note.moderator_message && related_mod_note.moderator_message.slice(0),
            original: related_mod_note,
            editing: true
        };

        // update validation, update the markdown editor
        $scope.validateRelatedModNote();
        $scope.updateEditor();
    };

    $scope.validateRelatedModNote = function() {
        var note = $scope.activeRelatedModNote;
        if (!note) return;

        // set mods array
        note.mods = [note.mod_id, $scope.mod.id];

        // validation helpers
        var sanitized_text = contributionService.removePrompts(note.text_body);
        var textValid = sanitized_text.length > 128;
        var modsValid = note.mod_id !== undefined;

        // related mod note is valid if all parts valid
        $scope.$applyAsync(function() {
            $scope.activeRelatedModNote.charCount = sanitized_text.length;
            $scope.activeRelatedModNote.valid = textValid && modsValid;
        });
    };

    var validationTimeout;
    $scope.noteChanged = function() {
        clearTimeout(validationTimeout);
        validationTimeout = setTimeout($scope.validateRelatedModNote, 100);
    };

    // discard the related mod note object
    $scope.discardRelatedModNote = function() {
        if ($scope.activeRelatedModNote.editing) {
            $scope.activeRelatedModNote.original.editing = false;
            $scope.activeRelatedModNote = null;
        } else {
            delete $scope.activeRelatedModNote;
        }
    };

    // update a related mod note locally
    $scope.updateRelatedModNote = function(updatedNote) {
        var originalNote = $scope.activeRelatedModNote.original;
        // update the values on the original note
        originalNote.text_body = updatedNote.text_body.slice(0);
        originalNote.moderator_message = updatedNote.moderator_message && updatedNote.moderator_message.slice(0);
        originalNote.status = updatedNote.status;
    };

    // save a related mod note
    $scope.saveRelatedModNote = function() {
        var relatedModNote = $scope.activeRelatedModNote;
        if (!relatedModNote.valid) return;

        // submit the related mod note
        var sanitized_text = contributionService.removePrompts(relatedModNote.text_body);
        var noteObj = {
            related_mod_note: {
                game_id: $scope.mod.game_id,
                status: relatedModNote.status,
                first_mod_id: $scope.mod.id,
                second_mod_id: relatedModNote.mod_id,
                text_body: sanitized_text,
                edit_summary: relatedModNote.edit_summary,
                moderator_message: relatedModNote.moderator_message
            }
        };
        relatedModNote.submitting = true;

        // use update or submit contribution
        if (relatedModNote.editing) {
            var noteId = relatedModNote.original.id;
            contributionService.updateContribution("related_mod_notes", noteId, noteObj).then(function() {
                $scope.$emit("successMessage", "Related Mod Note updated successfully.");
                // update original related mod note and discard copy
                $scope.updateRelatedModNote(noteObj.related_mod_note);
                $scope.discardRelatedModNote();
            }, function(response) {
                var params = { label: 'Error updating Related Mod Note', response: response };
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("related_mod_notes", noteObj).then(function(note) {
                $scope.$emit("successMessage", "Related Mod Note submitted successfully.");
                $scope.mod.related_mod_notes.unshift(note);
                $scope.discardRelatedModNote();
            }, function(response) {
                var params = { label: 'Error submitting Related Mod Note', response: response };
                $scope.$emit('errorMessage', params);
            });
        }
    };
});
