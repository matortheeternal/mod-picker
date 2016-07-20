app.controller('modListToolsController', function($scope, $state, $stateParams, modListService) {
    $scope.retrieveTools = function() {
        $scope.retrieving.tools = true;
        modListService.retrieveModListTools($scope.mod_list.id).then(function(data) {
            $scope.mod_list.tools = data;
            $scope.retrieving.tools = false;
            // TODO: Retrieve this from the backend
            $scope.mod_list.missing_tools = [];
            $scope.originalModList.tools = angular.copy($scope.mod_list.tools);
        }, function(response) {
            $scope.errors.tools = response;
        });
    };

    // retrieve tools if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.tools && !$scope.retrieving.tools) {
        $scope.retrieveTools();
    }
});