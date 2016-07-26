app.controller('modInstallOrderController', function($scope, $stateParams, $state, contributionService, contributionFactory) {
    // verify we can access this tab
    $scope.currentTab = $scope.findTab('Install Order');
    if (!$scope.currentTab) {
        // if we can't access this tab, redirect to the first tab we can access and
        // stop doing stuff in this controller
        $state.go('base.mod.' + $scope.tabs[0].name, {
            modId: $stateParams.modId
        });
        return;
    }

    // BASE RETRIEVAL LOGIC
    $scope.retrieveInstallOrderNotes = function(page) {
        $scope.retrieving.install_order_notes = true;

        // transition to new url state
        var params = {
            modId: $stateParams.modId,
            page: page,
            scol: $scope.sort.compatibility_notes.column,
            sdir: $scope.sort.compatibility_notes.direction
        };
        $state.transitionTo('base.mod.Install Order', params, { notify: false });

        // retrieve the install order notes
        var options = {
            sort: $scope.sort.install_order_notes,
            filters: $scope.filters.install_order_notes,
            page: page || 1
        };
        contributionService.retrieveModContributions($stateParams.modId, 'install_order_notes', options, $scope.pages.install_order_notes).then(function(data) {
            $scope.retrieving.install_order_notes = false;
            $scope.mod.install_order_notes = data;
        }, function(response) {
            $scope.errors.install_order_notes = response;
        });
    };

    // retrieve install order notes if we don't have them and aren't currently retrieving them
    if (!$scope.mod.install_order_notes && !$scope.retrieving.install_order_notes) {
        $scope.sort.install_order_notes.column = $stateParams.scol;
        $scope.sort.install_order_notes.direction = $stateParams.sdir;
        $scope.retrieveInstallOrderNotes($stateParams.page);
    }

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
            contributionService.updateContribution("install_order_notes", noteId, noteObj).then(function() {
                $scope.$emit("successMessage", "Install Order Note updated successfully.");
                // update original install order note and discard copy
                $scope.updateInstallOrderNote(noteObj.install_order_note);
                $scope.discardInstallOrderNote();
            }, function(response) {
                var params = {label: 'Error updating Install Order Note', response: response};
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("install_order_notes", noteObj).then(function(note) {
                $scope.$emit("successMessage", "Install Order Note submitted successfully.");
                $scope.mod.reviews.unshift(note);
                $scope.discardInstallOrderNote();
            }, function(response) {
                var params = {label: 'Error submitting Install Order Note', response: response};
                $scope.$emit('errorMessage', params);
            });
        }
    };
});