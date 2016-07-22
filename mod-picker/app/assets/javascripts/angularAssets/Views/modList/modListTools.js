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
            // We put this in shared because we don't want to detect changes to it as changes
            // to the mod list itself.  Changes in requirements are due to tools being added
            // or removed.
            $scope.shared.required_tools = data.required_tools;
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

    $scope.reAddTool = function(modListTool) {
        // if tool is already present on the user's mod list but has been
        // removed, add it back
        if (modListTool._destroy) {
            delete modListTool._destroy;
            $scope.mod_list.tools_count += 1;
            $scope.reAddRequirements($scope.shared.required_tools, modListTool.id);
            $scope.buildMissingTools($scope.shared.required_tools, $scope.mod_list.tools);
            $scope.updateTabs();
            $scope.$emit('successMessage', 'Added tool ' + modListTool.mod.name + ' successfully.');
        }
        // else inform the user that the tool is already on their mod list
        else {
            $scope.$emit('customMessage', {type: 'error', text: 'Failed to add tool ' + modListTool.mod.name + ', the tool has already been added to this mod list.'});
        }
    };

    $scope.addNewTool = function(toolId) {
        // retrieve tool information from the backend
        modListService.newModListMod(toolId).then(function(data) {
            // prepare tool
            var modListTool = data;
            // we delete this because it's null, would be better if we just didn't render it though
            delete modListTool.id;
            modListTool.mod_id = modListTool.mod.id;

            // push tool onto view
            // TODO: Handle new requirements
            // TODO: Handle missing requirements
            $scope.mod_list.tools.push(modListTool);
            $scope.model.tools.push(modListTool);
            $scope.mod_list.tools_count += 1;
            $scope.updateTabs();
            $scope.$emit('successMessage', 'Added tool ' + modListTool.mod.name + ' successfully.');
        }, function(response) {
            var params = {label: 'Error adding tool', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addTool = function() {
        // return if we don't have a tool to add
        if (!$scope.add.tool.id) {
            return;
        }

        // see if the tool is already present on the user's mod list
        var existingTool = $scope.mod_list.tools.find(function(modListTool) {
            return modListTool.mod.id == $scope.add.tool.id;
        });
        if (existingTool) {
            $scope.reAddTool(existingTool);
        } else {
            $scope.addNewTool($scope.add.tool.id);
        }

        // reset tool search
        $scope.add.tool.id = null;
        $scope.add.tool.name = "";
    };

    $scope.removeTool = function(array, index) {
        $scope.removeItem(array, index);
        $scope.buildMissingTools($scope.shared.required_tools, $scope.mod_list.tools);
        $scope.mod_list.tools_count -= 1;
        $scope.updateTabs();
    };

    $scope.$on('rebuildModels', function() {
        $scope.buildToolsModel($scope.mod_list.tools, $scope.mod_list.groups);
        $scope.buildMissingTools($scope.shared.required_tools, $scope.mod_list.tools);
    });
});