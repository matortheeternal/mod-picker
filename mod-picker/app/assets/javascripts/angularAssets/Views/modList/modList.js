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
        templateUrl: '/resources/partials/modList/modListDetails.html',
        controller: 'modListDetailsController',
        url: '/details'
    }).state('base.mod-list.Tools', {
        templateUrl: '/resources/partials/modList/modListTools.html',
        controller: 'modListToolsController',
        url: '/tools?scol&sdir',
        params: {
            scol: 'index',
            sdir: 'asc'
        }
    }).state('base.mod-list.Mods', {
        templateUrl: '/resources/partials/modList/modListMods.html',
        controller: 'modListModsController',
        url: '/mods?scol&sdir',
        params: {
            scol: 'index',
            sdir: 'asc'
        }
    }).state('base.mod-list.Plugins', {
        templateUrl: '/resources/partials/modList/modListPlugins.html',
        controller: 'modListPluginsController',
        url: '/plugins?scol&sdir',
        params: {
            scol: 'index',
            sdir: 'asc'
        }
    }).state('base.mod-list.Config', {
        templateUrl: '/resources/partials/modList/modListConfig.html',
        controller: 'modListConfigController',
        url: '/config'
    }).state('base.mod-list.Comments', {
        templateUrl: '/resources/partials/modList/modListComments.html',
        controller: 'modListCommentsController',
        url: '/comments'
    })
}]);

app.controller('modListController', function($scope, $q, $stateParams, $timeout, currentUser, modListObject, modListService, errorService, objectUtils, tabsFactory, listUtils) {
    // get parent variables
    $scope.mod_list = modListObject.mod_list;
    $scope.mod_list.star = modListObject.star;
    $scope.mod_list.groups = [];
    $scope.originalModList = angular.copy($scope.mod_list);
    $scope.currentUser = currentUser;

	// initialize local variables
    $scope.tabs = tabsFactory.buildModListTabs($scope.mod_list);
    $scope.pages = {
        comments: {}
    };
    $scope.model = {};
    $scope.newTags = [];
    $scope.required = {};
    $scope.notes = {};
    $scope.retrieving = {}; // this can be removed when we make states sticky
    $scope.show = { // this can be removed when we make states sticky
        missing_tools: true,
        missing_mods: true,
        unresolved_compatibility: true,
        unresolved_install_order: true
    };
    $scope.add = {
        tool: {},
        mod: {}
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
    $scope.isEmpty = objectUtils.isEmptyArray;

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
            $scope.flattenModels();
            var modListDiff = objectUtils.getDifferentObjectValues($scope.originalModList, $scope.mod_list);
            if (!objectUtils.isEmptyObject(modListDiff)) {
                var message = {type: 'warning', text: 'Your mod list has unsaved changes.'};
                $scope.$broadcast('message', message);
            }
        }
    };

    // MOD LIST EDITING LOGIC
    $scope.flattenModel = function(label) {
        if ($scope.model[label]) {
            $scope.mod_list[label] = [];
            $scope.model[label].forEach(function(item) {
                if (item.children) {
                    $scope.mod_list.groups.push(item);
                    item.children.forEach(function(child) {
                        $scope.mod_list[label].push(child);
                    })
                } else {
                    $scope.mod_list[label].push(item);
                }
            });
        }
    };

    $scope.flattenModels = function() {
        $scope.mod_list.groups = [];
        $scope.flattenModel('tools');
        $scope.flattenModel('mods');
        $scope.flattenModel('plugins');
    };

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

    $scope.findTool = function(toolId, ignoreDestroyed) {
        var foundTool = listUtils.findMod($scope.model.tools, toolId);
        if (foundTool && ignoreDestroyed && foundTool._destroy) {
            return;
        }
        return foundTool;
    };

    $scope.findMod = function(modId, ignoreDestroyed) {
        var foundMod = listUtils.findMod($scope.model.mods, modId);
        if (foundMod && ignoreDestroyed && foundMod._destroy) {
            return;
        }
        return foundMod;
    };

    $scope.addGroup = function(tab) {
        var model = $scope.model[tab];
        var newGroup = {
            mod_list_id: $scope.mod_list.id,
            index: model.length,
            tab: tab,
            color: 'red',
            name: 'New Group'
        };
        modListService.newModListGroup(newGroup).then(function(data) {
            var group = data;
            group.children = [];
            $scope.mod_list.groups.push(group);
            $scope.originalModList.groups.push(angular.copy(group));
            model.push(group);
        }, function(response) {
            var params = {label: 'Error creating new Mod List Group', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.reAddRequirements = function(modId) {
        var reAddMatchingRequirements = function(item) {
            if (item._destroy && item.mod.id == modId) {
                delete item._destroy;
            }
        };
        var req = $scope.required; // an alias to make the code a bit shorter
        req.mods && req.mods.forEach(reAddMatchingRequirements);
        req.tools && req.tools.forEach(reAddMatchingRequirements);
    };

    $scope.reAddNotes = function(modId) {
        var reAddMatchingNotes = function(note) {
            if (note._destroy && note.mods[0].id == modId || note.mods[1].id == modId) {
                delete note._destroy;
            }
        };
        var nts = $scope.notes; // an alias to make the code a bit shorter
        nts.compatibility && nts.compatibility.forEach(reAddMatchingNotes);
        nts.install_order && nts.install_order.forEach(reAddMatchingNotes);
    };

    $scope.removeRequirements = function(modId) {
        var destroyMatchingRequirements = function(requirement) {
            if (requirement.mod.id == modId) {
                requirement._destroy = true;
            }
        };
        var req = $scope.required; // an alias to make the code a bit shorter
        req.mods && req.mods.forEach(destroyMatchingRequirements);
        req.tools && req.tools.forEach(destroyMatchingRequirements);
    };

    $scope.removeNotes = function(modId) {
        var destroyMatchingNotes = function(note) {
            if (note.mods[0].id == modId || note.mods[1].id == modId) {
                note._destroy = true;
            }
        };
        $scope.notes.compatibility.forEach(destroyMatchingNotes);
        $scope.notes.install_order.forEach(destroyMatchingNotes);
    };

    $scope.$on('rebuildMissing', function() {
        $scope.$broadcast('rebuildMissingTools');
        $scope.$broadcast('rebuildMissingMods');
    });

    $scope.$on('rebuildUnresolved', function() {
        $scope.$broadcast('rebuildUnresolvedCompatibility');
        $scope.$broadcast('rebuildUnresolvedInstallOrder');
        $scope.$broadcast('rebuildUnresolvedLoadOrder');
    });

    $scope.removeDestroyedItems = function() {
        var removeIfDestroyed = function(item, index, array) {
            if (item._destroy) {
                array.splice(index, 1);
            }
        };
        var ml = $scope.mod_list; // an alias to make the code a bit shorter
        ml.mods && ml.mods.forEach(removeIfDestroyed);
        ml.tools && ml.tools.forEach(removeIfDestroyed);
        ml.groups && ml.groups.forEach(removeIfDestroyed);
        var req = $scope.required; // an alias to make the code a bit shorter
        req.mods && req.mods.forEach(removeIfDestroyed);
        req.tools && req.tools.forEach(removeIfDestroyed);
    };

    $scope.recoverDestroyedItems = function() {
        var recoverIfDestroyed = function(item) {
            if (item._destroy) {
                delete item._destroy;
            }
        };
        var req = $scope.required; // an alias to make the code a bit shorter
        req.mods && req.mods.forEach(recoverIfDestroyed);
        req.tools && req.tools.forEach(recoverIfDestroyed);
    };

    $scope.saveChanges = function() {
        // get changed mod fields
        $scope.flattenModels();
        var modListDiff = objectUtils.getDifferentObjectValues($scope.originalModList, $scope.mod_list);
        if (objectUtils.isEmptyObject(modListDiff)) {
            var message = {type: 'warning', text: 'There are no changes to save.'};
            $scope.$broadcast('message', message);
            return;
        }

        modListService.updateModList(modListDiff).then(function() {
            $scope.$emit('successMessage', 'Mod list saved successfully.');
            $scope.removeDestroyedItems();
            delete $scope.originalModList;
            $scope.originalModList = angular.copy($scope.mod_list);
        }, function(response) {
            $scope.$emit('errorMessage', {label: 'Error saving mod list', response: response});
        });
    };

    $scope.discardChanges = function() {
        if (confirm("Are you sure you want to discard your changes?")) {
            $scope.mod_list = angular.copy($scope.originalModList);
            $scope.recoverDestroyedItems();
            $scope.$broadcast('rebuildModels');
            $scope.$broadcast('rebuildMissingTools');
            $scope.$broadcast('rebuildMissingMods');
            $scope.updateTabs();
        }
    };
});