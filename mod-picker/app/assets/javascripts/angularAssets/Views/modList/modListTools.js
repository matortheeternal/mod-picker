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
                var insertIndex = $scope.model.tools.findIndex(function(item) {
                    return item.index > tool.index;
                });
                $scope.model.tools.splice(insertIndex, 0, tool);
            }
        });
    };

    $scope.buildMissingTools = function(required_tools, tools) {
        $scope.shared.missing_tools = [];
        required_tools.forEach(function(requirement) {
            var toolPresent = tools.find(function(modListTool) {
                return !modListTool._destroy && modListTool.mod.id == requirement.required_mod.id;
            });
            if (!toolPresent) {
                $scope.shared.missing_tools.push(requirement);
            }
        });
    };

    $scope.retrieveTools = function() {
        $scope.retrieving.tools = true;
        modListService.retrieveModListTools($scope.mod_list.id).then(function(data) {
            $scope.buildMissingTools(data.required_tools, data.tools);
            $scope.buildToolsModel(data.tools, data.groups);
            $scope.mod_list.required_tools = data.required_tools;
            $scope.mod_list.tools = data.tools;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.tools = angular.copy($scope.mod_list.tools);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.retrieving.tools = false;
        }, function(response) {
            $scope.errors.tools = response;
        });
    };

    // retrieve tools if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.tools && !$scope.retrieving.tools) {
        $scope.retrieveTools();
    }

    $scope.addToolGroup = function() {
        var newGroup = {
            mod_list_id: $scope.mod_list.id,
            index: $scope.model.tools.length,
            tab: 'tools',
            color: 'red',
            name: 'New Group'
        };
        modListService.newModListGroup(newGroup).then(function(data) {
            var group = data;
            group.children = [];
            $scope.mod_list.groups.push(group);
            $scope.originalModList.groups.push(angular.copy(group));
            $scope.model.tools.push(group);
        }, function(response) {
            var params = {label: 'Error creating new Mod List Group', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.$on('rebuildModels', function() {
        $scope.buildToolsModel($scope.mod_list.tools, $scope.mod_list.groups);
        $scope.buildMissingTools($scope.mod_list.required_tools, $scope.mod_list.tools);
    });
});