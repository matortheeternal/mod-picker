app.controller('userSettingsModsController', function($scope, columnsFactory, actionsFactory, modService) {
    // initialize variables
    $scope.actions = actionsFactory.userModActions();
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();

    // BASE RETRIEVAL LOGIC
    $scope.retrieveMods = function() {
        var options = {
            filters: {
                mp_author: $scope.user.username,
                include_adult: true,
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
});