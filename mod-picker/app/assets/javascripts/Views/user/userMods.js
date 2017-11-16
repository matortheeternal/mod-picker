app.controller('userModsController', function($scope, errorService, modService, userService, columnsFactory, actionsFactory, modListService, indexFactory) {
    // initialize variables
    $scope.actions = actionsFactory.modIndexActions();
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();

    // INHERITED FUNCTIONS
    indexFactory.miniIndex($scope, function(page, pageInfo) {
        return userService.retrieveAuthoredMods($scope.user.id, {
            page: page || 1,
            game: window._current_game_id
        }, pageInfo);
    }, 'mods', 'authoredMods');

    indexFactory.miniIndex($scope, function(page, pageInfo) {
        return userService.retrieveSubmittedMods($scope.user.id, {
            page: page || 1,
            game: window._current_game_id
        }, pageInfo);
    }, 'mods', 'submittedMods');

    indexFactory.miniIndex($scope, function(page, pageInfo) {
        return userService.retrieveFavoriteMods($scope.user.id, {
            page: page || 1,
            game: window._current_game_id
        }, pageInfo);
    }, 'mods', 'favoriteMods');

    // DATA RETRIEVAL
    $scope.retrieveAuthoredMods();
    $scope.retrieveSubmittedMods();
    $scope.retrieveFavoriteMods();

    // adds a mod to the user's mod list
    $scope.$on('addMod', function(event, mod) {
        modListService.addModListMod($scope.activeModList, mod).then(function() {
            $scope.$emit('successMessage', 'Added mod "'+mod.name+'" to your mod list successfully.');
        }, function(response) {
            var params = {
                label: 'Error adding mod "'+mod.name+'" to your mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });

    // removes a mod from the user's mod list
    $scope.$on('removeMod', function(event, mod) {
        modListService.removeModListMod($scope.activeModList, mod).then(function() {
            $scope.$emit('successMessage', 'Removed mod "'+mod.name+'" from your mod list successfully.');
        }, function(response) {
            var params = {
                label: 'Error removing mod "'+mod.name+'" from your mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });
});