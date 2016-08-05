app.controller('modListToolsController', function($scope, $rootScope, $state, $stateParams, $timeout, modListService, modService, listUtils, columnsFactory, actionsFactory) {
    // initialize variables
    $scope.showDetailsModal = false;
    $scope.detailsItem = {};
    $scope.columns = columnsFactory.modListModColumns();
    $scope.columnGroups = columnsFactory.modListModColumnGroups();
    $scope.actions = actionsFactory.modListToolActions();
    $scope.searchTools = modService.searchModListTools;

    $scope.toggleDetailsModal = function(visible, item) {
        $scope.$emit('toggleModal', visible);
        $scope.showDetailsModal = visible;
        $scope.detailsItem = item;
    };

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
        var tools = $scope.mod_list.tools.concat($scope.mod_list.custom_tools);
        tools.forEach(function(tool) {
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

    $scope.retrieveTools = function() {
        modListService.retrieveModListTools($scope.mod_list.id).then(function(data) {
            $scope.required.tools = data.required_tools;
            $scope.mod_list.tools = data.tools;
            $scope.mod_list.custom_tools = data.custom_tools;
            $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], data.groups);
            $scope.originalModList.tools = angular.copy($scope.mod_list.tools);
            $scope.originalModList.custom_tools = angular.copy($scope.mod_list.custom_tools);
            $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
            $scope.buildToolsModel();
            $timeout(function() {
                $scope.$broadcast('initializeModules');
            }, 100);
            $scope.toolsReady = true;
        }, function(response) {
            $scope.errors.tools = response;
        });
    };

    // retrieve tools when the state is first loaded
    $scope.retrieveTools();

    $scope.recoverTool = function(modListTool) {
        // if tool is already present on the user's mod list but has been
        // removed, add it back
        if (modListTool._destroy) {
            delete modListTool._destroy;
            $scope.mod_list.tools_count += 1;
            $scope.updateTabs();

            // upudate modules
            $rootScope.$broadcast('modRecovered', !!modListTool.mod && modListTool.mod.id);
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
            index: listUtils.getNextIndex($scope.model.tools)
        };

        modListService.newModListMod(mod_list_mod).then(function(data) {
            // push tool onto view
            var modListTool = data.mod_list_mod;
            $scope.mod_list.tools.push(modListTool);
            $scope.model.tools.push(modListTool);
            $scope.originalModList.tools.push(angular.copy(modListTool));
            $scope.mod_list.tools_count += 1;
            $scope.updateTabs();

            // update modules
            $rootScope.$broadcast('modAdded', data);
            $scope.$broadcast('updateItems');

            // success message
            $scope.$broadcast('updateItems');
            $scope.$emit('successMessage', 'Added tool ' + modListTool.mod.name + ' successfully.');
        }, function(response) {
            var params = {label: 'Error adding tool', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addCustomTool = function() {
        var custom_tool = {
            mod_list_id: $scope.mod_list.id,
            index: listUtils.getNextIndex($scope.model.tools),
            is_utility: true,
            name: 'Custom Tool'
        };

        modListService.newModListCustomMod(custom_tool).then(function(data) {
            // push plugin onto view
            var modListCustomTool = data.mod_list_custom_mod;
            $scope.mod_list.custom_tools.push(modListCustomTool);
            $scope.model.tools.push(modListCustomTool);
            $scope.originalModList.custom_tools.push(angular.copy(modListCustomTool));
            $scope.mod_list.tools_count += 1;
            $scope.updateTabs();

            // update modules
            $scope.$broadcast('customModAdded');
            $scope.$broadcast('updateItems');

            // open plugin details for custom plugin
            $scope.toggleDetailsModal(true, modListCustomTool);
        }, function(response) {
            var params = {label: 'Error adding custom tool', response: response};
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
        $rootScope.$broadcast('modRemoved', !!modListTool.mod && modListTool.mod.id);
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
    $scope.$on('toggleDetailsModal', function(event, options) {
        $scope.toggleDetailsModal(options.visible, options.item);
    });
});