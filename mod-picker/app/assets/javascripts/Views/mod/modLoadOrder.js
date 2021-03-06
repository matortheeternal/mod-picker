app.controller('modLoadOrderController', function($scope, $state, $stateParams, modService, pluginService, contributionService, contributionFactory, sortFactory) {
    $scope.sort.load_order_notes = {
        column: $stateParams.scol,
        direction: $stateParams.sdir
    };
    $scope.filters.load_order_notes = $stateParams.filter;
    $scope.pages.load_order_notes.current = $stateParams.page || 1;

    // inherited functions
    $scope.searchPlugins = pluginService.searchPlugins;

    // functions
    $scope.retrieveLoadOrderNotes = function(page) {
        // retrieve the Load Order Notes
        var options = {
            sort: $scope.sort.load_order_notes,
            filters: $scope.filters.load_order_notes,
            page: page || $scope.pages.load_order_notes.current
        };
        modService.retrieveModContributions($stateParams.modId, 'load_order_notes', options, $scope.pages.load_order_notes).then(function(data) {
            $scope.mod.load_order_notes = data;
            if ($scope.errors.load_order_notes) delete $scope.errors.load_order_notes;

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

    // re-retrieve load order notes when the sort object changes
    // this will be called once automatically when the tab loads when we
    // build the sort object at line 2 in this controller
    $scope.$watch('sort.load_order_notes', function() {
        $scope.retrieveLoadOrderNotes();
    }, true);

    // LOAD ORDER NOTE RELATED LOGIC
    // instantiate a new load order note object
    $scope.startNewLoadOrderNote = function() {
        // set up activeLoadOrderNote object
        $scope.activeLoadOrderNote = {
            first_plugin_filename: $scope.mod.plugins[0].filename,
            order: "before",
            text_body: contributionFactory.getDefaultTextBody("LoadOrderNote")
        };

        // update validation, update the markdown editor
        $scope.validateLoadOrderNote();
        $scope.updateEditor();
    };

    // edit an existing load order note
    $scope.editLoadOrderNote = function(load_order_note) {
        load_order_note.editing = true;

        // update the markdown editor
        $scope.updateEditor();
        load_order_note.editing = true;
        var order, searchText, firstPluginFilename, secondPluginFilename;
        if (load_order_note.first_mod.id != $scope.mod.id) {
            searchText = load_order_note.first_plugin.filename;
            order = 'after';
            firstPluginFilename = load_order_note.second_plugin_filename;
            secondPluginFilename = load_order_note.first_plugin_filename;
        } else {
            searchText = load_order_note.second_plugin.filename;
            order = 'before';
            firstPluginFilename = load_order_note.first_plugin_filename;
            secondPluginFilename = load_order_note.second_plugin_filename;
        }
        $scope.activeLoadOrderNote = {
            first_plugin_filename: firstPluginFilename,
            second_plugin_filename: secondPluginFilename,
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
        var loadOrderNote = $scope.activeLoadOrderNote;
        if (!loadOrderNote) return;

        var sanitized_text = contributionService.removePrompts(loadOrderNote.text_body);
        var textValid = sanitized_text.length > 128;
        var pluginsValid = (loadOrderNote.first_plugin_filename !== undefined) &&
            (loadOrderNote.second_plugin_filename !== undefined);

        // load order note is valid if all parts are valid
        $scope.$applyAsync(function() {
            $scope.activeLoadOrderNote.charCount = sanitized_text.length;
            $scope.activeLoadOrderNote.valid = textValid && pluginsValid;
        });
    };

    var validationTimeout;
    $scope.noteChanged = function() {
        clearTimeout(validationTimeout);
        validationTimeout = setTimeout($scope.validateLoadOrderNote, 100);
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
        if ((originalNote.first_plugin_filename == updatedNote.second_plugin_filename) &&
            (originalNote.second_plugin_filename == updatedNote.first_plugin_filename)) {
            originalNote.mods.reverse();
            originalNote.plugins.reverse();
            originalNote.first_plugin_filename = originalNote.first_plugin.filename;
            originalNote.second_plugin_filename = originalNote.second_plugin.filename;
        }
        originalNote.text_body = updatedNote.text_body.slice(0);
        originalNote.moderator_message = updatedNote.moderator_message && updatedNote.moderator_message.slice(0);
    };

    // submit a load order note
    $scope.saveLoadOrderNote = function() {
        var loadOrderNote = $scope.activeLoadOrderNote;
        if (!loadOrderNote.valid) return;

        // prepare load order note fields for submission
        var sanitized_text = contributionService.removePrompts(loadOrderNote.text_body);
        var first_plugin_filename, second_plugin_filename;
        if (loadOrderNote.order === 'before') {
            first_plugin_filename = loadOrderNote.first_plugin_filename;
            second_plugin_filename = loadOrderNote.second_plugin_filename;
        } else {
            first_plugin_filename = loadOrderNote.second_plugin_filename;
            second_plugin_filename = loadOrderNote.first_plugin_filename;
        }

        // submit the load order note
        var noteObj = {
            load_order_note: {
                game_id: $scope.mod.game_id,
                first_plugin_filename: first_plugin_filename,
                second_plugin_filename: second_plugin_filename,
                text_body: sanitized_text,
                edit_summary: loadOrderNote.edit_summary,
                moderator_message: loadOrderNote.moderator_message
            }
        };
        loadOrderNote.submitting = true;

        // use update or submit contribution
        if (loadOrderNote.editing) {
            var noteId = loadOrderNote.original.id;
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
                $scope.mod.load_order_notes.unshift(note);
                $scope.discardLoadOrderNote();
            }, function(response) {
                var params = { label: 'Error submitting Load Order Note', response: response };
                $scope.$emit('errorMessage', params);
            });
        }
    };
});
