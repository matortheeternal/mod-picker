app.controller('userSettingsModsController', function($scope, columnsFactory, actionsFactory, modService) {
    // initialize variables
    $scope.actions = actionsFactory.userModActions();
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();

    // BASE RETRIEVAL LOGIC
    $scope.retrieveMods = function() {
        var options = {
            filters: {
                game: window._current_game_id,
                search: "mp_author:" + $scope.user.username,
                sources: {
                    nexus: true,
                    lab: true,
                    workshop: true,
                    other: true
                }
            }
        };
        var pages = {};
        modService.retrieveMods(options, pages).then(function(data) {
            $scope.mods = data.mods;
        }, function(response) {
            $scope.errors.mods = response;
        });
    };

    //retrieve the mod lists when the state is first loaded
    $scope.retrieveMods();

    // action handlers
    $scope.$on('hideMod', function(event, mod) {
        modService.hideMod(mod.id, true).then(function() {
            mod.hidden = true;
            $scope.$emit('successMessage', 'Mod hidden successfully.');
        }, function(response) {
            var params = {
                label: 'Error hiding mod',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });

    $scope.$on('recoverMod', function(event, mod) {
        modService.hideMod(mod.id, false).then(function() {
            mod.hidden = false;
            $scope.$emit('successMessage', 'Mod recovered successfully.');
        }, function(response) {
            var params = {
                label: 'Error recovering mod',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });
});