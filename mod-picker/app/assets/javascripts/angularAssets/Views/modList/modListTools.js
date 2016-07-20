app.controller('modListToolsController', function($scope, $state, $stateParams, modListService) {
    $scope.buildToolsModel = function(tools, groups) {
        $scope.model.tools = [];
        groups.forEach(function(group) {
            if (group.tab !== 'tools') {
                return;
            }
            $scope.model.tools.push(group);
            group.children = tools.filter(function(tool) {
                return tool.group_id == group.id;
            });
        });
        tools.forEach(function(tool) {
            if (!tool.group_id) {
                $scope.model.tools.push(tool);
            }
        });
    };

    $scope.retrieveTools = function() {
        $scope.retrieving.tools = true;
        modListService.retrieveModListTools($scope.mod_list.id).then(function(data) {
            $scope.buildToolsModel(data.tools, data.groups);
            $scope.mod_list.tools = data.tools;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.tools = angular.copy($scope.mod_list.tools);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            // TODO: Retrieve this from the backend
            $scope.mod_list.missing_tools = [];
            $scope.retrieving.tools = false;
        }, function(response) {
            $scope.errors.tools = response;
        });
    };

    // retrieve tools if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.tools && !$scope.retrieving.tools) {
        $scope.retrieveTools();
    }
});