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
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Details': {
                templateUrl: '/resources/partials/modList/modListDetails.html',
                controller: 'modListDetailsController'
            }
        },
        url: '/details'
    }).state('base.mod-list.Tools', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Tools': {
                templateUrl: '/resources/partials/modList/modListTools.html',
                controller: 'modListToolsController'
            }
        },
        url: '/tools?scol&sdir',
        params: {
            scol: 'index',
            sdir: 'asc'
        }
    }).state('base.mod-list.Mods', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Mods': {
                templateUrl: '/resources/partials/modList/modListMods.html',
                controller: 'modListModsController'
            }
        },
        url: '/mods?scol&sdir',
        params: {
            scol: 'index',
            sdir: 'asc'
        }
    }).state('base.mod-list.Plugins', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Plugins': {
                templateUrl: '/resources/partials/modList/modListPlugins.html',
                controller: 'modListPluginsController'
            }
        },
        url: '/plugins?scol&sdir',
        params: {
            scol: 'index',
            sdir: 'asc'
        }
    }).state('base.mod-list.Config', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Config': {
                templateUrl: '/resources/partials/modList/modListConfig.html',
                controller: 'modListConfigController'
            }
        },
        url: '/config'
    }).state('base.mod-list.Analysis', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Analysis': {
                templateUrl: '/resources/partials/modList/modListAnalysis.html',
                controller: 'modListAnalysisController'
            }
        },
        url: '/analysis'
    }).state('base.mod-list.Comments', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Comments': {
                templateUrl: '/resources/partials/modList/modListComments.html',
                controller: 'modListCommentsController'
            }
        },
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
    $scope.errors = {};
    $scope.add = {
        tool: {},
        mod: {},
        plugin: {},
        config: {}
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
    $scope.flattenModel = function(label, associationLabel) {
        var custom_label = 'custom_' + label;
        if ($scope.model[label]) {
            $scope.mod_list[label] = [];
            $scope.mod_list[custom_label] = [];
            $scope.model[label].forEach(function(item) {
                if (item.children) {
                    $scope.mod_list.groups.push(item);
                    item.children.forEach(function(child) {
                        if (child.hasOwnProperty(associationLabel)) {
                            $scope.mod_list[label].push(child);
                        } else {
                            $scope.mod_list[custom_label].push(child);
                        }
                    })
                } else if (item.hasOwnProperty(associationLabel)) {
                    $scope.mod_list[label].push(item);
                } else {
                    $scope.mod_list[custom_label].push(item);
                }
            });
        }
    };

    $scope.flattenModels = function() {
        $scope.mod_list.groups = [];
        $scope.flattenModel('tools', 'mod');
        $scope.flattenModel('mods', 'mod');
        $scope.flattenModel('plugins', 'plugin');
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
        if (!$scope.model.tools) {
            return true;
        }
        var foundTool = listUtils.findMod($scope.model.tools, toolId);
        if (foundTool && ignoreDestroyed && foundTool._destroy) {
            return;
        }
        return foundTool;
    };

    $scope.findMod = function(modId, ignoreDestroyed) {
        if (!$scope.model.mods) {
            return true;
        }
        var foundMod = listUtils.findMod($scope.model.mods, modId);
        if (foundMod && ignoreDestroyed && foundMod._destroy) {
            return;
        }
        return foundMod;
    };

    $scope.findPlugin = function(pluginId, ignoreDestroyed) {
        if (!$scope.model.plugins) {
            return true;
        }
        var foundPlugin = listUtils.findPlugin($scope.model.plugins, pluginId);
        if (foundPlugin && ignoreDestroyed && foundPlugin._destroy) {
            return;
        }
        return foundPlugin;
    };

    $scope.findCustomPlugin = function(noteId, ignoreDestroyed) {
        if (!$scope.model.plugins) {
            return false;
        }
        var foundPlugin = listUtils.findCustomPlugin($scope.model.plugins, noteId);
        if (foundPlugin && ignoreDestroyed && foundPlugin._destroy) {
            return;
        }
        return foundPlugin;
    };

    $scope.findIgnoredNote = function(note_type, note_id, ignoreDestroyed) {
        var foundIgnoredNote = $scope.mod_list.ignored_notes.find(function(ignoredNote) {
            return ignoredNote.note_type === note_type && ignoredNote.note_id == note_id;
        });
        if (foundIgnoredNote && ignoreDestroyed && foundIgnoredNote._destroy) {
            return;
        }
         return foundIgnoredNote;
    };

    $scope.findConfig = function(configId, ignoreDestroyed) {
        if (!$scope.model.configs) {
            return true;
        }
        var foundConfig = listUtils.findConfig($scope.model.configs, configId);
        if (foundConfig && ignoreDestroyed && foundConfig._destroy) {
            return;
        }
        return foundConfig;
    };

    $scope.associateIgnore = function(notes, note_type) {
        notes.forEach(function(note) {
            note.ignored = !!$scope.findIgnoredNote(note_type, note.id, true);
        });
    };

    $scope.addGroup = function(tab) {
        var model = $scope.model[tab];
        var newGroup = {
            mod_list_id: $scope.mod_list.id,
            index: listUtils.getNextIndex(model) - 1,
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
            var params = {label: 'Error creating new group', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.ignoreNote = function(type, note) {
        if (note.ignored) {
            var foundIgnoredNote = $scope.findIgnoredNote(type, note.id);
            if (note.ignored) {
                if (!foundIgnoredNote) {
                    $scope.mod_list.ignored_notes.push({
                        note_type: type,
                        note_id: note.id
                    });
                } else if (foundIgnoredNote._destroy) {
                    delete foundIgnoredNote._destroy;
                }
            } else if (foundIgnoredNote) {
                if (foundIgnoredNote.id) {
                    foundIgnoredNote._destroy = true;
                } else {
                    var index = $scope.mod_list.ignored_notes.indexOf(foundIgnoredNote);
                    $scope.mod_list.ignored_notes.splice(index, 1);
                }
            }
        }
    };

    $scope.saveChanges = function() {
        // get changed mod fields
        $scope.flattenModels();
        var modListDiff = objectUtils.getDifferentObjectValues($scope.originalModList, $scope.mod_list);
        // if no fields were changed, inform the user
        if (objectUtils.isEmptyObject(modListDiff)) {
            var message = {type: 'warning', text: 'There are no changes to save.'};
            $scope.$broadcast('message', message);
            return;
        }

        modListService.updateModList(modListDiff).then(function() {
            // update modules
            $scope.$broadcast('saveChanges');
            // success message
            $scope.$emit('successMessage', 'Mod list saved successfully.');
        }, function(response) {
            $scope.$emit('errorMessage', {label: 'Error saving mod list', response: response});
        });
    };

    $scope.discardChanges = function() {
        if (confirm("Are you sure you want to discard your changes?")) {
            // discard changes
            $scope.mod_list = angular.copy($scope.originalModList);
            // update modules
            $scope.$broadcast('rebuildModels');
            $scope.$broadcast('reloadModules');
            $scope.updateTabs();
        }
    };

    // event triggers
    $scope.$on('reloadModules', function() {
        // recover destroyed groups
        if ($scope.mod_list.groups) {
            listUtils.recoverDestroyed($scope.mod_list.groups);
        }
    });
    $scope.$on('saveChanges', function() {
        // remove destroyed groups
        if ($scope.mod_list.groups) {
            listUtils.removeDestroyed($scope.mod_list.groups);
        }
        // set originalModList to the current version of mod_list
        delete $scope.originalModList;
        $scope.originalModList = angular.copy($scope.mod_list);
    })
});