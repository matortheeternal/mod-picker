app.controller('modListModsController', function($scope, modListService) {
    $scope.retrieveMods = function() {
        $scope.retrieving.mods = true;
        modListService.retrieveModListMods($scope.mod_list.id).then(function(data) {
            $scope.mod_list.mods = data;
            $scope.retrieving.mods = false;
            // TODO: Retrieve this from the backend
            $scope.mod_list.missing_mods = [];
            $scope.originalModList.mods = angular.copy($scope.mod_list.mods);
        }, function(response) {
            $scope.errors.mods = response;
        });
    };

    // retrieve mods if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.mods && !$scope.retrieving.mods) {
        $scope.retrieveMods();
    }
});