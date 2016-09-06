app.controller('userModsController', function($scope, columnsFactory, actionsFactory, modService, userService) {
    // initialize variables
    $scope.actions = actionsFactory.modIndexActions();
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();

    // BASE RETRIEVAL LOGIC
    $scope.retrieveMods = function() {
        userService.retrieveUserMods($scope.user.id).then(function(data) {
            $scope.authored_mods = data.authored;
            $scope.favorite_mods = data.favorite;
        }, function(response) {
            $scope.errors.mods = response;
        });
    };

    //retrieve the mods when the state is first loaded
    $scope.retrieveMods();
});