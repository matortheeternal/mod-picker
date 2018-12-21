app.controller('userSettingsModListsController', function($scope, $rootScope, $timeout, columnsFactory, actionsFactory, modListService) {
    // initialize variables
    $scope.actions = actionsFactory.userModListActions();
    $scope.columns = columnsFactory.modListColumns();
    $scope.columnGroups = columnsFactory.modListColumnGroups();
    $scope.model = {
        activeModListId: $scope.activeModList && $scope.activeModList.id
    };
    $scope.activeModListChange = function(newValue) {
        $scope.activeModListId = newValue;
    };

    var currentGame = $rootScope.games.find(function(game) {
        return game.id === window._current_game_id;
    });
    var isSkyrimClassic = currentGame.display_name === 'Skyrim';
    var skyrimSE = $rootScope.games.find(function(game) {
        return game.display_name === 'Skyrim SE';
    });

    // BASE RETRIEVAL LOGIC
    $scope.retrieveModLists = function() {
        var options = {
            filters: {
                game: isSkyrimClassic ? [window._current_game_id, skyrimSE.id] :
                    window._current_game_id,
                search: "submitter:" + $scope.user.username
            }
        };
        var pages = {};
        modListService.retrieveModLists(options, pages).then(function(data) {
            $scope.all_mod_lists = data.mod_lists;
            $scope.mod_lists = [];
            $scope.collections = [];
            data.mod_lists.forEach(function(item) {
                var model = item.is_collection ? $scope.collections : $scope.mod_lists;
                model.push(item);
            });

            $scope.available_lists = $scope.all_mod_lists.filter(function(list) {
                var game = $rootScope.games.find(function(game) {
                    return game.id === list.game_id;
                });
                list.game = game && game.display_name;
                return !list.hidden;
            });
        }, function(response) {
            $scope.errors.mod_lists = response;
        });
    };

    //retrieve the mod lists when the state is first loaded
    $scope.retrieveModLists();

    // CREATE A NEW MOD LIST
    $scope.newModList = function(is_collection) {
        var mod_list = {
            game_id: window._current_game_id,
            name: $scope.currentUser.username + "'s Mod List",
            is_collection: is_collection,
            // TODO: Should have a default description set on the backend
            description: "A brand new mod list!"
        };
        var model = is_collection ? $scope.collections : $scope.mod_lists;
        var label = is_collection ? 'mod collection' : 'mod list';
        modListService.newModList(mod_list, false).then(function(data) {
            $scope.all_mod_lists.push(data.mod_list);
            model.push(data.mod_list);
            $scope.$emit('successMessage', 'Created new ' + label + ' successfully.');
        }, function(response) {
            var params = {
                label: 'Error creating new ' + label,
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    };

    // SAVE ACTIVE MOD LIST
    $scope.saveActiveModList = function() {
        var modListId = $scope.model.activeModListId || null;
        modListService.setActiveModList(modListId).then(function(data) {
            data.mod_list.game = $rootScope.games.find(function(game) {
                return game.id === data.mod_list.game_id;
            });
            $rootScope.activeModList = data.mod_list;
            $scope.$emit('successMessage', 'Set active mod list successfully.');
        }, function(response) {
            var params = {
                label: 'Error setting active mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.removeActiveModList = function(modList) {
        var index = $scope.all_mod_lists.findIndex(function(item) {
            return modList.id === item.id;
        });
        if (index > -1) $scope.all_mod_lists.splice(index, 1);
    };

    $scope.unsetActiveModList = function(modList) {
        if ($scope.activeModList && $scope.activeModList.id === modList.id) {
            $rootScope.activeModList = null;
            $scope.model.activeModListId = null;
        }
    };

    $scope.hideModList = function(modList) {
        modList.hidden = true;
        $scope.unsetActiveModList(modList);
    };

    $scope.deleteModList = function(modList) {
        var model = modList.is_collection ? $scope.collections : $scope.mod_lists;
        var index = model.findIndex(function(item) {
            return item.id === modList.id;
        });
        if (index > -1) model.splice(index, 1);
        $scope.unsetActiveModList(modList);
        $scope.removeActiveModList(modList);
    };

    // ACTION HANDLERS
    $scope.$on('cloneModList', function(event, modList) {
        modListService.cloneModList(modList.id).then(function(data) {
            $rootScope.activeModList = data.mod_list;
            $scope.$emit('customMessage', {
                type: "success",
                text: "Cloned mod list successfully.  Click here to view it.",
                url: "mod-lists/" + data.mod_list.id
            });
        }, function(response) {
            $scope.$emit('errorMessage', {
                label: 'Error cloning mod list',
                response: response
            });
        });
    });

    $scope.$on('deleteModList', function(event, modList) {
        modListService.hideModList(modList.id, true).then(function() {
            if ($scope.permissions.canModerate) {
                $scope.hideModList(modList);
            } else {
                $scope.deleteModList(modList);
            }
            $scope.available_lists.splice($scope.available_lists.indexOf(modList), 1);
            $scope.model.activeModListId = "";
            $scope.$emit('successMessage', 'Mod list deleted successfully.');
        }, function(response) {
            var params = {
                label: 'Error deleting mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });

    $scope.$on('recoverModList', function(event, modList) {
        modListService.hideModList(modList.id, false).then(function() {
            modList.hidden = false;
            $scope.available_lists.push(modList);
            $scope.$emit('successMessage', 'Mod list recovered successfully.');
        }, function(response) {
            var params = {
                label: 'Error recovering mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });
});
