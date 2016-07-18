app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.mod-list', {
        templateUrl: '/resources/partials/modList/modList.html',
        controller: 'modListController',
        url: '/mod-list/:modListId',
        redirectTo: 'base.mod-list.Details',
        resolve: {
            modListObject: function(modListService, $stateParams, $q) {
                var modList = $q.defer();
                modListService.retrieveModList($stateParams.modListId).then(function(data) {
                    modList.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error retrieving mod list.',
                        response: response,
                        stateName: 'base.mod-list',
                        stateUrl: window.location.hash
                    };
                    modList.reject(errorObj);
                });
                return modList.promise;
            }
        }
    }).state('base.mod-list.Details', {
        templateUrl: '/resources/partials/modList/details.html',
        controller: 'modListDetailsController',
        url: '/details'
    }).state('base.mod-list.Tools', {
        templateUrl: '/resources/partials/modList/tools.html',
        controller: 'modListToolsController',
        url: '/tools?scol&sdir',
        params: {
            scol: 'index',
            sdir: 'asc'
        }
    }).state('base.mod-list.Mods', {
        templateUrl: '/resources/partials/modList/mods.html',
        controller: 'modListModsController',
        url: '/mods?scol&sdir',
        params: {
            scol: 'index',
            sdir: 'asc'
        }
    }).state('base.mod-list.Plugins', {
        templateUrl: '/resources/partials/modList/plugins.html',
        controller: 'modListPluginsController',
        url: '/plugins?scol&sdir',
        params: {
            scol: 'index',
            sdir: 'asc'
        }
    }).state('base.mod-list.Config', {
        templateUrl: '/resources/partials/modList/config.html',
        controller: 'modListConfigController',
        url: '/config'
    }).state('base.mod-list.Comments', {
        templateUrl: '/resources/partials/modList/comments.html',
        controller: 'modListCommentsController',
        url: '/comments'
    })
}]);

app.controller('modListController', function($scope, $q, $stateParams, $timeout, currentUser, modListObject, modListService, errorService, objectUtils, tabsFactory, sortFactory) {
    // get parent variables
    $scope.mod_list = modListObject.mod_list;
    $scope.mod_list.star = modListObject.star;
    $scope.originalModList = angular.copy($scope.mod_list);
    $scope.currentUser = currentUser;

	// initialize local variables
    $scope.tabs = tabsFactory.buildModListTabs($scope.mod_list);
    $scope.newTags = [];
    $scope.retrieving = {};
    $scope.add = {};
    $scope.sort = {
        tools: {},
        mods: {},
        plugins: {},
        config: {}
    };
    $scope.sortOptions = {
        tools: sortFactory.modListToolSortOptions(),
        mods: sortFactory.modListModSortOptions(),
        plugins: 0, //sortFactory.modListPluginSortOptions(),
        config: 0 //sortFactory.modListConfigSortOptions()
    };
    $scope.statusIcons = {
        under_construction: 'fa-wrench',
        testing: 'fa-cogs',
        complete: 'fa-check'
    };
    $scope.statusClasses = {
        under_construction: 'red-box',
        testing: 'yellow-box',
        complete: 'green-box'
    };
    $scope.statusHints = {
        under_construction: 'This mod list is in the process of being built.',
        testing: 'This mod list is in the process of being tested.',
        complete: 'This mod list has been completed.'
    };
    $scope.visibilityIcons = {
        visibility_private: 'fa-eye-slash',
        visibility_unlisted: 'fa-share-alt',
        visibility_public: 'fa-eye'
    };
    $scope.visibilityClasses = {
        visibility_private: 'red-box',
        visibility_unlisted: 'yellow-box',
        visibility_public: 'green-box'
    };
    $scope.visibilityHints = {
        visibility_private: 'Only the mod list creator and moderators \ncan view this mod list.',
        visibility_unlisted: "This mod list won't appear in search results, \nbut anyone can access it.",
        visibility_public: "This mod list is publicly available and will \nappear in search results."
    };

    // a copy is created so the original permissions object is never changed
    $scope.permissions = angular.copy(currentUser.permissions);
    // setting up the canManage permission
    var isAuthor = $scope.mod_list.submitter.id == $scope.currentUser.id;
    $scope.permissions.canManage = $scope.permissions.canModerate || isAuthor;

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response, $scope.mod_list.id);
        errors.forEach(function(error) {
            $scope.$broadcast('message', error);
        });
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display success message
    $scope.$on('successMessage', function(event, text) {
        var successMessage = {type: 'success', text: text};
        $scope.$broadcast('message', successMessage);
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display custom message
    $scope.$on('customMessage', function(event, message) {
        $scope.$broadcast('message', message);
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // HEADER RELATED LOGIC
    $scope.starModList = function() {
        modListService.starModList($scope.mod_list.id, $scope.mod_list.star).then(function() {
            $scope.mod_list.star = !$scope.mod_list.star;
        }, function(response) {
            var params = {label: 'Error starring mod list', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.toggleEditing = function() {
        $scope.editing = !$scope.editing;
        if (!$scope.editing) {
            var modListDiff = objectUtils.getDifferentObjectValues($scope.originalModList, $scope.mod_list);
            if (!objectUtils.isEmptyObject(modListDiff)) {
                var message = {type: 'warning', text: 'Your mod list has unsaved changes.'};
                $scope.$broadcast('message', message);
            }
        }
        // update tab counts
        $scope.updateTabs();
    };

    // MOD LIST EDITING LOGIC
    $scope.updateTabs = function() {
        $scope.tabs.forEach(function(tab) {
            switch (tab.name) {
                case "Tools":
                    tab.count = $scope.mod_list.tools_count;
                    break;
                case "Mods":
                    tab.count = $scope.mod_list.mods_count;
                    break;
                case "Plugins":
                    tab.count = $scope.mod_list.plugins_count;
                    break;
                case "Config":
                    tab.count = $scope.mod_list.config_files_count;
                    break;
            }
        });
    };

    $scope.removeMod = function(mod, isTool) {
        mod._destroy = true;
        // update counts
        if (isTool) {
            $scope.mod_list.tools_count -= 1;
        } else {
            $scope.mod_list.mods_count -= 1;
        }
        $scope.updateTabs();
    };

    $scope.saveChanges = function() {
        // get changed mod fields
        var modListDiff = objectUtils.getDifferentObjectValues($scope.originalModList, $scope.mod_list);
        if (objectUtils.isEmptyObject(modListDiff)) {
            var message = {type: 'warning', text: 'There are no changes to save.'};
            $scope.$broadcast('message', message);
            return;
        }

        modListService.updateModList(modListDiff).then(function() {
            $scope.$emit('successMessage', 'Mod list saved successfully.');
            delete $scope.originalModList;
            $scope.originalModList = angular.copy($scope.mod_list);
        }, function(response) {
            $scope.$emit('errorMessage', {label: 'Error saving mod list', response: response});
        });
    };

    $scope.discardChanges = function() {
        if (confirm("Are you sure you want to discard your changes?")) {
            $scope.mod_list = angular.copy($scope.originalModList);
            $scope.updateTabs();
        }
    };
});

app.controller('modListDetailsController', function($scope, tagService) {
    $scope.saveTags = function(updatedTags) {
        var action = $q.defer();
        tagService.updateModListTags($scope.mod_list, updatedTags).then(function(data) {
            $scope.$emit('successMessage', 'Tags updated successfully.');
            action.resolve(data);
        }, function(response) {
            var params = {label: 'Error saving mod list tags', response: response};
            $scope.$emit('errorMessage', params);
            action.reject(response);
        });
        return action.promise;
    };
});

app.controller('modListToolsController', function($scope, $state, $stateParams, modListService) {
    $scope.retrieveTools = function() {
        $scope.retrieving.tools = true;

        // transition to new url state
        var params = {
            modListId: $stateParams.modListId,
            scol: $scope.sort.tools.column,
            sdir: $scope.sort.tools.direction
        };
        $state.transitionTo('base.mod-list.Tools', params, { notify: false });

        // retrieve the tools
        modListService.retrieveModListTools($scope.mod_list.id).then(function(data) {
            $scope.mod_list.tools = data;
            // TODO: Retrieve this from the backend
            $scope.mod_list.missing_tools = [];
            $scope.originalModList.tools = angular.copy($scope.mod_list.tools);
        }, function(response) {
            $scope.errors.tools = response;
        });
    };

    // retrieve tools if we don't have them and aren't currently retrieving them
    if (!$scope.mod_list.tools && !$scope.retrieving.tools) {
        $scope.sort.tools.column = $stateParams.scol;
        $scope.sort.tools.direction = $stateParams.sdir;
        $scope.retrieveTools();
    }

    // ADD A TOOL
    $scope.resetToolSearch = function() {
        $scope.add.toolId = null;
        $scope.add.toolName = "";
    };

    $scope.addTool = function() {
        // return if we don't have a tool to add
        if (!$scope.add.toolId) {
            return;
        }

        // see if the tool is already present on the user's mod list
        var existingTool = $scope.mod_list.tools.find(function(tool) {
            return tool.mod.id == $scope.add.toolId;
        });
        if (existingTool) {
            // if tool is already present on the user's mod list but has been
            // removed, add it back
            if (existingTool._destroy) {
                delete existingTool._destroy;
                $scope.mod_list.tools_count += 1;
                $scope.updateTabs();
                $scope.$emit('successMessage', 'Added tool ' + $scope.add.toolName + ' successfully.');
            }
            // else inform the user that the tool is already on their mod list
            else {
                $scope.$emit('customMessage', {type: 'error', text: 'Failed to add tool ' + $scope.add.toolName + ', the tool has already been added to this mod list.'});
            }
        } else {
            // retrieve tool information from the backend
            modListService.newModListMod($scope.add.toolId).then(function(data) {
                // prepare tool
                var tool = data;
                delete tool.id;
                tool.mod_id = tool.mod.id;

                // push tool onto view
                $scope.mod_list.tools.push(tool);
                $scope.mod_list.tools_count += 1;
                $scope.updateTabs();
                $scope.$emit('successMessage', 'Added tool ' + $scope.add.toolName + ' successfully.');
            }, function(response) {
                var params = {label: 'Error adding tool', response: response};
                $scope.$emit('errorMessage', params);
            });
        }

        // reset tool search
        $scope.resetToolSearch();
    };
});

app.controller('modListModsController', function($scope) {

});

app.controller('modListPluginsController', function($scope) {

});

app.controller('modListConfigController', function($scope) {

});

app.controller('modListCommentsController', function($scope) {

});
