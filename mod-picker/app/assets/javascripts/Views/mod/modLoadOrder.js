app.controller('modLoadOrderController', function($scope, $state, $stateParams, modService, pluginService, contributionService, contributionFactory, sortFactory) {
    $scope.sort.load_order_notes = {
        column: $stateParams.scol,
        direction: $stateParams.sdir
    };
    $scope.filters.load_order_notes = $stateParams.filter;

    // inherited functions
    $scope.searchPlugins = pluginService.searchPlugins;

    // functions
    $scope.retrieveLoadOrderNotes = function(page) {
        // retrieve the Load Order Notes
        var options = {
            sort: $scope.sort.load_order_notes,
            filters: $scope.filters.load_order_notes,
            //if no page is specified load the first one
            page: page || 1
        };
        modService.retrieveModContributions($stateParams.modId, 'load_order_notes', options, $scope.pages.load_order_notes).then(function(data) {
            $scope.mod.load_order_notes = data;

            //seperating the loadOrderNote in the url if any
            if ($stateParams.loadOrderNoteId) {
                var currentIndex = $scope.mod.load_order_notes.findIndex(function(loadOrderNote) {
                    return loadOrderNote.id === $stateParams.loadOrderNoteId;
                });
                if (currentIndex > -1) {
                    $scope.currentLoadOrderNote = $scope.mod.load_order_notes.splice(currentIndex, 1)[0];
                } else {
                    // remove the loadOrderNote param from the url if it's not part of this mod
                    $state.go($state.current.name, {loadOrderNote: null});
                }
            } else {
                // clear the currentLoadOrderNote if it's not specified
                delete $scope.currentLoadOrderNote;
            }
        }, function(response) {
            $scope.errors.load_order_notes = response;
        });

        //refresh the tab's params
        var params = {
            scol: $scope.sort.load_order_notes.column,
            sdir: $scope.sort.load_order_notes.direction,
            filter: $scope.filters.load_order_notes.modlist,
            page: page || 1
        };
        $state.go($state.current.name, params);
    };

    //retrieve the notes when the state is first loaded
    $scope.retrieveLoadOrderNotes($stateParams.page);

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
            originalNote.first_plugin_id = originalNote.first_plugin.id;
            originalNote.second_plugin_id = originalNote.second_plugin.id;
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
                var params = { label: 'Error updating Load Order Note', response: response };
                $scope.$emit('errorMessage', params);
            });
        } else {
            contributionService.submitContribution("load_order_notes", noteObj).then(function(note) {
                $scope.$emit("successMessage", "Load Order Note submitted successfully.");
                $scope.mod.reviews.unshift(note);
                $scope.discardLoadOrderNote();
            }, function(response) {
                var params = { label: 'Error submitting Load Order Note', response: response };
                $scope.$emit('errorMessage', params);
            });
        }
    };
});