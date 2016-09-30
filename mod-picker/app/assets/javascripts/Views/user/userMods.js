app.controller('userModsController', function($scope, errorService, modService, userService, columnsFactory, actionsFactory, modListService) {
    // initialize variables
    $scope.actions = actionsFactory.modIndexActions();
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();

    // BASE RETRIEVAL LOGIC
    $scope.retrieveMods = function() {
        userService.retrieveUserMods($scope.user.id).then(function(data) {
            $scope.authored_mods = data.authored;
            $scope.favorite_mods = data.favorites;
        }, function(response) {
            $scope.errors.mods = response;
        });
    };

    //retrieve the mods when the state is first loaded
    $scope.retrieveMods();

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