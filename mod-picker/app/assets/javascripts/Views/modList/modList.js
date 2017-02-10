// redirects for the old url format of /mod-list/:modListId
app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.oldModList', {
        url: '/mod-list/:modListId',
        redirectTo: 'base.modList'
    }).state('base.oldModList.Details', {
        url: '/details',
        redirectTo: 'base.modList.Details'
    }).state('base.oldModList.Tools', {
        url: '/tools?scol&sdir',
        redirectTo: 'base.modList.Tools'
    }).state('base.oldModList.Mods', {
        url: '/mods?scol&sdir',
        redirectTo: 'base.modList.Mods'
    }).state('base.oldModList.Plugins', {
        url: '/plugins?scol&sdir',
        redirectTo: 'base.modList.Plugins'
    }).state('base.oldModList.Config', {
        url: '/config',
        redirectTo: 'base.modList.Config'
    }).state('base.oldModList.Analysis', {
        url: '/analysis',
        redirectTo: 'base.modList.Analysis'
    }).state('base.oldModList.Comments', {
        url: '/comments',
        redirectTo: 'base.modList.Comments'
    })
}]);

app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.modList', {
        templateUrl: '/resources/partials/modList/modList.html',
        controller: 'modListController',
        url: '/mod-lists/:modListId',
        redirectTo: 'base.modList.Details',
        resolve: {
            modListObject: function(modListService, $stateParams, $q) {
                var modList = $q.defer();
                modListService.retrieveModList($stateParams.modListId).then(function(data) {
                    modList.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error retrieving mod list.',
                        response: response,
                        stateName: 'base.modList',
                        stateUrl: window.location.hash
                    };
                    modList.reject(errorObj);
                });
                return modList.promise;
            }
        }
    }).state('base.modList.Details', {
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
    }).state('base.modList.Tools', {
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
            sdir: 'ASC'
        }
    }).state('base.modList.Mods', {
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
            sdir: 'ASC'
        }
    }).state('base.modList.Plugins', {
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
            sdir: 'ASC'
        }
    }).state('base.modList.Config', {
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
    }).state('base.modList.Analysis', {
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
    }).state('base.modList.Comments', {
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

app.controller('modListController', function($scope, $rootScope, $q, $state, $stateParams, $timeout, modListObject, modListService, objectUtils, helpFactory, tabsFactory, baseFactory, eventHandlerFactory, listUtils) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.activeModList = $rootScope.activeModList;
    $scope.permissions = angular.copy($rootScope.permissions);

    // main view model variables
    $scope.mod_list = modListObject.mod_list;
    $scope.mod_list.star = modListObject.star;
    $scope.mod_list.groups = [];
    $scope.originalModList = angular.copy($scope.mod_list);
    $scope.removedModIds = [];

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
    $scope.report = {
        reportable_id: $scope.mod_list.id,
        reportable_type: 'ModList'
    };
    $scope.modelObj = {
        name: "ModList",
        label: "ModList",
        route: "mod-list"
    };
    $scope.target = $scope.mod_list;
    $scope.isActive = $scope.activeModList && $scope.activeModList.id == $scope.mod_list.id;

    // default to editing modlist if it's the current user's active modlist
    $scope.editing = $scope.isActive;

    // set page title
    $scope.$emit('setPageTitle', 'View Mod List');

    // shared function setup
    $scope.isEmpty = objectUtils.isEmptyArray;
    eventHandlerFactory.buildMessageHandlers($scope, true);

    // set up the canManage permission
    var isAuthor = $scope.mod_list.submitter.id == $scope.currentUser.id;
    $scope.permissions.isAuthor = isAuthor;
    $scope.permissions.canManage = $scope.permissions.canModerate || isAuthor;

    // DISABLE SAVE/RESET BUTTONS ON TABS THAT ARE NOT EDITABLE
    $scope.$on('$stateChangeSuccess', function(event, toState) {
        var tabName = toState.name.split(".").slice(-1)[0];
        var uneditableTabs = ["Comments", "Analysis"];
        $scope.tabEditable = uneditableTabs.indexOf(tabName) == -1;
        $scope.$broadcast('resetSticky');
    });

    // set help context
    var helpContexts = helpFactory.modListContext($scope.mod_list, $scope.permissions.canManage, $scope.isActive);
    helpFactory.setHelpContexts($scope, helpContexts);

    // HEADER RELATED LOGIC
    $scope.starModList = function() {
        modListService.starModList($scope.mod_list.id, $scope.mod_list.star).then(function() {
            $scope.mod_list.star = !$scope.mod_list.star;
        }, function(response) {
            var params = {label: 'Error starring mod list', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.cloneModList = function() {
        modListService.cloneModList($scope.mod_list.id).then(function(data) {
            $rootScope.activeModList = data.mod_list;
            var params = {
                type: "success",
                text: "Cloned mod list successfully.  Click here to view it.",
                url: "mod-list/"+data.mod_list.id
            };
            $scope.$emit('customMessage', params);
        }, function(response) {
            var params = {label: 'Error cloning mod list', response: response};
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addModCollection = function() {
        modListService.addModCollection($scope.mod_list.id).then(function() {
            $scope.$emit('successMessage', "Added " + $scope.mod_list.name + " to your active mod list.");
        }, function(response) {
            var params = { label: 'Error adding mod collection to your active mod list', response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.toggleEditing = function() {
        $scope.editing = !$scope.editing;
        if (!$scope.editing) {
            // tell the user if there are unsaved changes
            $scope.flattenModels();
            var modListDiff = objectUtils.getDifferentObjectValues($scope.originalModList, $scope.mod_list);
            if (!objectUtils.isEmptyObject(modListDiff)) {
                var message = {type: 'warning', text: 'Your mod list has unsaved changes.'};
                $scope.$broadcast('message', message);
            }
        } else {
            // make the mod list the user's active mod list if it isn't their active
            // mod list and they authored it
            if  (!$scope.isActive && isAuthor) {
                modListService.setActiveModList($scope.mod_list.id).then(function(data) {
                    $rootScope.activeModList = data.mod_list;
                    $scope.$emit('successMessage', 'This is now your active mod list.');
                    $scope.isActive = true;
                }, function(response) {
                    var params = {
                        label: 'Error setting active mod list',
                        response: response
                    };
                    $scope.$emit('errorMessage', params);
                });
            }
        }
    };

    $scope.toggleReportModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showReportModal = visible;
    };

    // ACTIVITY MODAL
    $scope.startActivity = function(title) {
        $scope.activityTitle = title;
        $scope.activityComplete = false;
        $scope.$emit('toggleModal', true);
        $scope.showActivityModal = true;
    };

    $scope.setActivityMessage = function(message) {
        $scope.activityMessage = message;
    };

    $scope.completeActivity = function() {
        $scope.activityComplete = true;
    };

    $scope.closeActivityModal = function() {
        $scope.$emit('toggleModal', false);
        $scope.showActivityModal = false;
    };

    // MOD LIST EDITING LOGIC
    $scope.flattenModel = function(label, associationLabel, mainBase, customBase, pushGroups) {
        var groupBase = baseFactory.getModListGroupBase();
        var custom_label = 'custom_' + label;
        var cleanedItem;
        if ($scope.model[label]) {
            $scope.mod_list[label] = [];
            $scope.mod_list[custom_label] = [];
            $scope.model[label].forEach(function(item) {
                if (item.children) {
                    if (pushGroups) {
                        var cleanedGroup = objectUtils.cleanAttributes(item, groupBase);
                        $scope.mod_list.groups.push(cleanedGroup);
                    }
                    item.children.forEach(function(child) {
                        if (child.hasOwnProperty(associationLabel)) {
                            cleanedItem = objectUtils.cleanAttributes(child, mainBase);
                            $scope.mod_list[label].push(cleanedItem);
                        } else {
                            cleanedItem = objectUtils.cleanAttributes(child, customBase);
                            $scope.mod_list[custom_label].push(cleanedItem);
                        }
                    });
                } else if (item.hasOwnProperty(associationLabel)) {
                    cleanedItem = objectUtils.cleanAttributes(item, mainBase);
                    $scope.mod_list[label].push(cleanedItem);
                } else {
                    cleanedItem = objectUtils.cleanAttributes(item, customBase);
                    $scope.mod_list[custom_label].push(cleanedItem);
                }
            });
        }
    };

    $scope.flattenModels = function() {
        // prepare base objects for cleaning
        var customModBase = baseFactory.getCustomModBase();
        var modListModBase = baseFactory.getModListModBase();
        var modListPluginBase = baseFactory.getModListPluginBase();
        var customPluginBase = baseFactory.getCustomPluginBase();
        var modListConfigBase = baseFactory.getModListConfigFileBase();
        var customConfigBase = baseFactory.getCustomConfigFileBase();

        // flatten all models
        $scope.mod_list.groups = [];
        $scope.flattenModel('tools', 'mod', modListModBase, customModBase, true);
        $scope.flattenModel('mods', 'mod', modListModBase, customModBase, true);
        $scope.flattenModel('plugins', 'plugin', modListPluginBase, customPluginBase, true);
        $scope.flattenModel('config_files', 'config_file', modListConfigBase, customConfigBase);
    };

    $scope.updateTabs = function() {
        tabsFactory.updateModListTabs($scope.mod_list, $scope.tabs);
    };

    $scope.findTool = function(toolId, ignoreDestroyed) {
        return listUtils.genericFind($scope.model.tools, listUtils.findMod, toolId, ignoreDestroyed);
    };

    $scope.findMod = function(modId, ignoreDestroyed) {
        return listUtils.genericFind($scope.model.mods, listUtils.findMod, modId, ignoreDestroyed);
    };

    $scope.findPlugin = function(pluginId, ignoreDestroyed) {
        return listUtils.genericFind($scope.model.plugins, listUtils.findPlugin, pluginId, ignoreDestroyed);
    };

    $scope.findCustomPlugin = function(noteId, ignoreDestroyed) {
        return listUtils.genericFind($scope.model.plugins, listUtils.findCustomPlugin, noteId, ignoreDestroyed);
    };

    $scope.findConfig = function(configId, ignoreDestroyed) {
        return listUtils.genericFind($scope.model.config_files, listUtils.findConfig, configId, ignoreDestroyed);
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

    $scope.associateIgnore = function(notes, note_type) {
        notes.forEach(function(note) {
            note.ignored = !!$scope.findIgnoredNote(note_type, note.id, true);
        });
    };

    $scope.loadGroups = function(groups) {
        $scope.mod_list.groups = Array.prototype.concat($scope.mod_list.groups || [], groups);
        $scope.originalModList.groups = angular.copy($scope.mod_list.groups);
    };

    $scope.loadAndTrack = function(data, key) {
        $scope.mod_list[key] = data[key];
        $scope.originalModList[key] = angular.copy($scope.mod_list[key]);
    };

    $scope.loadNotes = function(data, key, modelKey, modelName) {
        $scope.notes[modelKey] = data[key];
        $scope.associateIgnore($scope.notes[modelKey], modelName);
    };

    $scope.addGroup = function(tab) {
        var model = $scope.model[tab];
        var newGroup = {
            mod_list_id: $scope.mod_list.id,
            index: listUtils.getNextIndex(model) - 1,
            tab: tab,
            color: 'red',
            name: 'New Group',
            keep_when_sorting: true
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
            $scope.createIgnoreNote(type, note);
        } else {
            $scope.destroyIgnoreNote(type, note);
        }
    };

    $scope.createIgnoreNote = function(type, note) {
        var foundIgnoredNote = $scope.findIgnoredNote(type, note.id);
        if (!foundIgnoredNote) {
            $scope.mod_list.ignored_notes.push({
                note_type: type,
                note_id: note.id
            });
        } else if (foundIgnoredNote._destroy) {
            delete foundIgnoredNote._destroy;
        }
    };

    $scope.destroyIgnoreNote = function(type, note) {
        var foundIgnoredNote = $scope.findIgnoredNote(type, note.id);
        if (foundIgnoredNote) {
            if (foundIgnoredNote.id) {
                foundIgnoredNote._destroy = true;
            } else {
                var index = $scope.mod_list.ignored_notes.indexOf(foundIgnoredNote);
                $scope.mod_list.ignored_notes.splice(index, 1);
            }
        }
    };

    $scope.updateCounters = function(updatedModList) {
        var counts = ["tools_count", "mods_count", "plugins_count"];
        counts.forEach(function(count) {
            $scope.mod_list[count] = updatedModList[count];
        });
        $scope.updateTabs();
    };

    $scope.saveChanges = function(skipFlatten) {
        var action = $q.defer();
        // get changed mod fields
        if (!skipFlatten) $scope.flattenModels();
        var modListDiff = objectUtils.getDifferentObjectValues($scope.originalModList, $scope.mod_list);
        // if no fields were changed, inform the user and return
        if (objectUtils.isEmptyObject(modListDiff)) {
            var message = {type: 'warning', text: 'There are no changes to save.'};
            $scope.$broadcast('message', message);
            action.resolve(false);
            return action.promise;
        }

        // else submit changes to the backend
        modListService.updateModList(modListDiff).then(function(data) {
            $rootScope.activeModList = data.mod_list;
            $scope.updateCounters(data.mod_list);
            $scope.$broadcast('saveChanges');
            $scope.$emit('successMessage', 'Mod list saved successfully.');
            action.resolve(true);
        }, function(response) {
            $scope.$emit('errorMessage', {label: 'Error saving mod list', response: response});
            action.reject(response);
        });

        return action.promise;
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

    // returns true if the mod list has been changed
    $scope.modListUnchanged = function() {
        $scope.flattenModels();
        var modListDiff = objectUtils.getDifferentObjectValues($scope.originalModList, $scope.mod_list);
        return objectUtils.isEmptyObject(modListDiff);
    };

    // returns true if the url is to the same mod list
    $scope.isLocalUrl = function(newUrl, oldUrl) {
        var newUrlParts = newUrl.split('/').slice(0, -1);
        var oldUrlParts = oldUrl.split('/').slice(0, -1);
        return newUrlParts.join('/') === oldUrlParts.join('/');
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
    });

    // help the user to not leave the page with unsaved changes
    $scope.$on("$locationChangeStart", function(event, newUrl, oldUrl) {
        // don't prompt if user can't edit the mod list or no changes have been made
        if (!$scope.permissions.canManage || $scope.modListUnchanged()) return;
        if ($scope.isLocalUrl(newUrl, oldUrl)) return;

        if (!confirm('Your mod list has unsaved changes, continue?')) {
            event.preventDefault();
        }
    });
});