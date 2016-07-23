app.controller('modLoadOrderController', function($scope, $state, $stateParams, contributionService, contributionFactory) {
    // verify we can access this tab
    $scope.currentTab = $scope.findTab('Load Order');
    if (!$scope.currentTab) {
        // if we can't access this tab, redirect to the first tab we can access and
        // stop doing stuff in this controller
        $state.go('base.mod.' + $scope.tabs[0].name, {
            modId: $stateParams.modId
        });
        return;
    }

    // BASE RETRIEVAL LOGIC
    $scope.retrieveLoadOrderNotes = function(page) {
        $scope.retrieving.load_order_notes = true;

        // transition to new url state
        var params = {
            modId: $stateParams.modId,
            page: page,
            scol: $scope.sort.load_order_notes.column,
            sdir: $scope.sort.load_order_notes.direction
        };
        $state.transitionTo('base.mod.Load Order', params, { notify: false });

        // retrieve the load order notes
        var options = {
            sort: $scope.sort.load_order_notes,
            filters: $scope.filters.load_order_notes,
            page: page || 1
        };
        contributionService.retrieveModContributions($stateParams.modId, 'load_order_notes', options, $scope.pages.load_order_notes).then(function(data) {
            $scope.retrieving.load_order_notes = false;
            $scope.mod.load_order_notes = data;
        }, function(response) {
            $scope.errors.load_order_notes = response;
        });
    };

    // retrieve laod order notes if we don't have them and aren't currently retrieving them
    if (!$scope.mod.load_order_notes && !$scope.retrieving.load_order_notes) {
        $scope.sort.load_order_notes.column = $stateParams.scol;
        $scope.sort.load_order_notes.direction = $stateParams.sdir;
        $scope.retrieveLoadOrderNotes($stateParams.page);
    }

    // re-retrieve load order notes when the sort object changes
    $scope.$watch('sort.load_order_notes', function() {
        $scope.retrieveLoadOrderNotes();
    }, true);

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
            contributionService.updateContribution("load_order_notes", noteId, noteObj).then(function() {
                $scope.$emit("successMessage", "Load Order Note updated successfully.");
                // update original load order note and discard copy
                $scope.updateLoadOrderNote(noteObj.load_order_note);
                $scope.discardLoadOrderNote();
            }, function(response) {
                var params = {label: 'Error updating Load Order Note', response: response};
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("load_order_notes", noteObj).then(function(note) {
                $scope.$emit("successMessage", "Load Order Note submitted successfully.");
                $scope.mod.reviews.unshift(note);
                $scope.discardLoadOrderNote();
            }, function(response) {
                var params = {label: 'Error submitting Load Order Note', response: response};
                $scope.$emit('errorMessage', params);
            });
        }
    };
});