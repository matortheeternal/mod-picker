app.controller('modListToolsController', function($scope, $state, $stateParams, modListService, modService, listUtils) {
    $scope.searchTools = modService.searchTools;

    $scope.buildToolsModel = function() {
        $scope.model.tools = [];
        $scope.mod_list.groups.forEach(function(group) {
            if (group.tab !== 'tools') {
                return;
            }
            $scope.model.tools.push(group);
            group.children = $scope.mod_list.tools.filter(function(tool) {
                return tool.group_id == group.id;
            });
        });
        $scope.mod_list.tools.forEach(function(tool) {
            if (!tool.group_id) {
                var insertIndex = $scope.model.tools.findIndex(function(item) {
                    return item.index > tool.index;
                });
                if (insertIndex == -1) {
                    insertIndex = $scope.model.tools.length;
                }
                $scope.model.tools.splice(insertIndex, 0, tool);
            }
        });
    };

    $scope.buildMissingTools = function() {
        $scope.required.missing_tools = [];
        $scope.required.tools.forEach(function(requirement) {
            if (requirement._destroy) {
                return;
            }
            var toolPresent = $scope.findTool(requirement.required_mod.id, true);
            if (!toolPresent) {
                $scope.required.missing_tools.push(requirement);
            }
        });
    };

    $scope.retrieveTools = function() {
        $scope.retrieving.tools = true;
        modListService.retrieveModListTools($scope.mod_list.id).then(function(data) {
            $scope.required.tools = data.required_tools;
            $scope.mod_list.tools = data.tools;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.tools = angular.copy($scope.mod_list.tools);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.buildToolsModel();
            $scope.$broadcast('initializeModules');
            $scope.retrieving.tools = false;
        }, function(response) {
            $scope.errors.tools = response;
        });
    };

    // retrieve tools if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.tools && !$scope.retrieving.tools) {
        $scope.retrieveTools();
    }

    $scope.recoverTool = function(modListTool) {
        // if tool is already present on the user's mod list but has been
        // removed, add it back
        if (modListTool._destroy) {
            delete modListTool._destroy;
            $scope.mod_list.tools_count += 1;
            $scope.updateTabs();

            // upudate modules
            $scope.$parent.$broadcast('modRecovered', modListTool.mod.id);
            $scope.$broadcast('updateItems');

            // success message
            $scope.$emit('successMessage', 'Added tool ' + modListTool.mod.name + ' successfully.');
        }
        // else inform the user that the tool is already on their mod list
        else {
            $scope.$emit('customMessage', {type: 'error', text: 'Failed to add tool ' + modListTool.mod.name + ', the tool has already been added to this mod list.'});
        }
    };

    $scope.addNewTool = function(toolId) {
        var mod_list_mod = {
            mod_list_id: $scope.mod_list.id,
            mod_id: toolId,
            index: $scope.mod_list.tools.length
        };

        modListService.newModListMod(mod_list_mod).then(function(data) {
            // push tool onto view
            $scope.mod_list.tools.push(data.mod_list_mod);
            $scope.model.tools.push(data.mod_list_mod);
            $scope.mod_list.tools_count += 1;
            $scope.updateTabs();

            // update modules
            $scope.$parent.$broadcast('modAdded', data);
            $scope.$broadcast('updateItems');

            // success message
            $scope.$broadcast('updateItems');
            $scope.$emit('successMessage', 'Added tool ' + data.mod_list_mod.mod.name + ' successfully.');
        }, function(response) {
            var params = {label: 'Error adding tool', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addTool = function(toolId) {
        // return if we don't have a tool to add
        if (!toolId) {
            return;
        }

        // see if the tool is already present on the user's mod list
        var existingTool = $scope.findTool(toolId);
        if (existingTool) {
            $scope.recoverTool(existingTool);
        } else {
            $scope.addNewTool(toolId);
        }

        if ($scope.add.tool.id) {
            $scope.add.tool.id = null;
            $scope.add.tool.name = "";
        }
    };

    $scope.removeTool = function(modListTool) {
        modListTool._destroy = true;
        $scope.mod_list.tools_count -= 1;
        $scope.updateTabs();

        // update modules
        $scope.$parent.$broadcast('modRemoved', modListTool.mod.id);
        $scope.$broadcast('updateItems');
    };

    // event triggers
    $scope.$on('removeMod', function(event, modId) {
        var foundTool = $scope.findTool(modId);
        if (foundTool) {
            $scope.removeTool(foundTool);
        }
    });
    $scope.$on('removeItem', function(event, modListTool) {
        $scope.removeTool(modListTool);
    });
    $scope.$on('rebuildModels', $scope.buildToolsModel);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.mod_list.tools);
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.mod_list.tools);
    });
});