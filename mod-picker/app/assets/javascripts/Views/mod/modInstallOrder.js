app.controller('modInstallOrderController', function($scope, $stateParams, $state, contributionService, modService, contributionFactory, sortFactory) {
    $scope.sort.install_order_notes = {
        column: $stateParams.scol,
        direction: $stateParams.sdir
    };
    $scope.filters.install_order_notes = $stateParams.filter;

    // inherited functions
    $scope.searchMods = modService.searchMods;

    // functions
    $scope.retrieveInstallOrderNotes = function(page) {
        // retrieve the Install Order Notes
        var options = {
            sort: $scope.sort.install_order_notes,
            filters: $scope.filters.install_order_notes,
            //if no page is specified load the first one
            page: page || 1
        };
        modService.retrieveModContributions($stateParams.modId, 'install_order_notes', options, $scope.pages.install_order_notes).then(function(data) {
            $scope.mod.install_order_notes = data;

            //seperating the installOrderNote in the url if any
            if ($stateParams.installOrderNoteId) {
                var currentIndex = $scope.mod.install_order_notes.findIndex(function(installOrderNote) {
                    return installOrderNote.id === $stateParams.installOrderNoteId;
                });
                if (currentIndex > -1) {
                    $scope.currentInstallOrderNote = $scope.mod.install_order_notes.splice(currentIndex, 1)[0];
                } else {
                    // remove the installOrderNoteId param from the url if it's not part of this mod
                    $state.go($state.current.name, {installOrderNoteId: null});
                }
            } else {
                // clear the currentInstallOrderNote if it's not specified
                delete $scope.currentInstallOrderNote;
            }
        }, function(response) {
            $scope.errors.install_order_notes = response;
        });

        //refresh the tab's params
        var params = {
            scol: $scope.sort.install_order_notes.column,
            sdir: $scope.sort.install_order_notes.direction,
            filter: $scope.filters.install_order_notes.modlist,
            page: page || 1
        };
        $state.go($state.current.name, params);
    };

    //retrieve the notes when the state is first loaded
    $scope.retrieveInstallOrderNotes($stateParams.page);

    // re-retrieve install order notes when the sort object changes
    $scope.$watch('sort.install_order_notes', function() {
        $scope.retrieveInstallOrderNotes();
    }, true);

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
        var mod, order;
        for (var i = 0; i < 2; i++) {
            if (install_order_note.mods[i].id != $scope.mod.id) {
                mod = install_order_note.mods[i];
                order = i == 0 ? 'after' : 'before';
            }
        }
        $scope.activeInstallOrderNote = {
            mod_id: mod.id.toString(),
            mod_name: mod.name,
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
            originalNote.first_mod_id = originalNote.first_mod.id;
            originalNote.second_mod_id = originalNote.second_mod.id;
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
            contributionService.updateContribution("install_order_notes", noteId, noteObj).then(function() {
                $scope.$emit("successMessage", "Install Order Note updated successfully.");
                // update original install order note and discard copy
                $scope.updateInstallOrderNote(noteObj.install_order_note);
                $scope.discardInstallOrderNote();
            }, function(response) {
                var params = { label: 'Error updating Install Order Note', response: response };
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("install_order_notes", noteObj).then(function(note) {
                $scope.$emit("successMessage", "Install Order Note submitted successfully.");
                $scope.mod.reviews.unshift(note);
                $scope.discardInstallOrderNote();
            }, function(response) {
                var params = { label: 'Error submitting Install Order Note', response: response };
                $scope.$emit('errorMessage', params);
            });
        }
    };
});