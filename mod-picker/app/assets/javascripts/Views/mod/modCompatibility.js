app.controller('modCompatibilityController', function($scope, $stateParams, $state, modService, pluginService, contributionFactory, contributionService, sortFactory) {
    $scope.sort.compatibility_notes = {
        column: $stateParams.scol,
        direction: $stateParams.sdir
    };
    $scope.filters.compatibility_notes.modlist = $stateParams.filter;
    $scope.pages.compatibility_notes.current = $stateParams.page || 1;

    // inherited functions
    $scope.searchMods = modService.searchMods;
    $scope.searchPlugins = pluginService.searchPlugins;

    // functions
    $scope.retrieveCompatibilityNotes = function(page) {
        // retrieve the compatibility notes
        var options = {
            sort: $scope.sort.compatibility_notes,
            filters: $scope.filters.compatibility_notes,
            page: page || $scope.pages.compatibility_notes.current
        };
        modService.retrieveModContributions($stateParams.modId, 'compatibility_notes', options, $scope.pages.compatibility_notes).then(function(data) {
            $scope.mod.compatibility_notes = data;

            //seperating the compatibilityNote in the url if any
            if ($stateParams.compatibilityNoteId) {
                var currentIndex = $scope.mod.compatibility_notes.findIndex(function(compatibilityNote) {
                    return compatibilityNote.id === $stateParams.compatibilityNoteId;
                });
                if (currentIndex > -1) {
                    $scope.currentCompatibilityNote = $scope.mod.compatibility_notes.splice(currentIndex, 1)[0];
                } else {
                    // remove the compatibilityNoteId param from the url if it's not part of this mod
                    $state.go($state.current.name, {compatibilityNoteId: null});
                }
            } else {
                // clear the currentCompatibilityNote if it's not specified
                delete $scope.currentCompatibilityNote;
            }
        }, function(response) {
            $scope.errors.compatibility_notes = response;
        });

        //refresh the tab's params
        var params = {
            scol: $scope.sort.compatibility_notes.column,
            sdir: $scope.sort.compatibility_notes.direction,
            filter: $scope.filters.compatibility_notes.modlist,
            page: page || 1
        };
        $state.go($state.current.name, params);
    };

    // re-retrieve compatibility note when the sort object changes
    // this will be called once automatically when the tab loads when we
    // build the sort object at line 2 in this controller
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
        var secondMod;
        if (compatibility_note.first_mod.id != $scope.mod.id) {
            secondMod = compatibility_note.first_mod;
        } else {
            secondMod = compatibility_note.second_mod;
        }
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
        var compatibilityNote = $scope.activeCompatibilityNote;
        if (!compatibilityNote) return;

        var sanitized_text = contributionService.removePrompts(compatibilityNote.text_body);
        var textValid = sanitized_text.length > 512;
        var modsValid = compatibilityNote.mod_id !== undefined;
        var statusValid = (compatibilityNote.status === "compatibility_mod") ==
            (compatibilityNote.compatibility_mod !== undefined);

        compatibilityNote.valid = textValid && modsValid && statusValid;
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
        var compatibilityNote = $scope.activeCompatibilityNote;
        if (!compatibilityNote.valid) return;

        // submit the compatibility note
        var sanitized_text = contributionService.removePrompts(compatibilityNote.text_body);
        var noteObj = {
            compatibility_note: {
                game_id: $scope.mod.game_id,
                status: compatibilityNote.status,
                first_mod_id: $scope.mod.id,
                second_mod_id: compatibilityNote.mod_id,
                text_body: sanitized_text,
                edit_summary: compatibilityNote.edit_summary,
                moderator_message: compatibilityNote.moderator_message,
                compatibility_plugin_id: compatibilityNote.compatibility_plugin_id,
                compatibility_mod_id: compatibilityNote.compatibility_mod_id
            }
        };
        compatibilityNote.submitting = true;

        // use update or submit contribution
        if (compatibilityNote.editing) {
            var noteId = compatibilityNote.original.id;
            contributionService.updateContribution("compatibility_notes", noteId, noteObj).then(function() {
                $scope.$emit("successMessage", "Compatibility Note updated successfully.");
                // update original compatibility note and discard copy
                $scope.updateCompatibilityNote(noteObj.compatibility_note);
                $scope.discardCompatibilityNote();
            }, function(response) {
                var params = { label: 'Error updating Compatibility Note', response: response };
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("compatibility_notes", noteObj).then(function(note) {
                $scope.$emit("successMessage", "Compatibility Note submitted successfully.");
                $scope.mod.compatibility_notes.unshift(note);
                $scope.discardCompatibilityNote();
            }, function(response) {
                var params = { label: 'Error submitting Compatibility Note', response: response };
                $scope.$emit('errorMessage', params);
            });
        }
    };
});
