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
    $scope.mod_list.groups = [];
    $scope.originalModList = angular.copy($scope.mod_list);
    $scope.currentUser = currentUser;

	// initialize local variables
    $scope.tabs = tabsFactory.buildModListTabs($scope.mod_list);
    $scope.model = {}; // this can be removed when we make states sticky
    $scope.newTags = [];
    $scope.retrieving = {}; // this can be removed when we make states sticky
    $scope.shared = {}; // this can be removed when we make states sticky
    $scope.show = { // this can be removed when we make states sticky
        missing_tools: true,
        missing_mods: true
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

    // add a mod or tool
    $scope.addMod = function(array, label) {
        // return if we don't have a tool to add
        var add = $scope.add[label];
        if (!add.id) {
            return;
        }

        // see if the tool is already present on the user's mod list
        var existingMod = array.find(function(item) {
            return item.mod.id == add.id;
        });
        var count_label = label + "s_count";
        if (existingMod) {
            // if tool is already present on the user's mod list but has been
            // removed, add it back
            if (existingMod._destroy) {
                delete existingMod._destroy;
                $scope.mod_list[count_label] += 1;
                $scope.updateTabs();
                $scope.$emit('successMessage', 'Added ' + label + ' ' + add.name + ' successfully.');
            }
            // else inform the user that the tool is already on their mod list
            else {
                $scope.$emit('customMessage', {type: 'error', text: 'Failed to add ' + label + ' ' + add.name + ', the ' + label + ' has already been added to this mod list.'});
            }
        } else {
            // retrieve tool information from the backend
            modListService.newModListMod(add.id).then(function(data) {
                // prepare tool
                var modItem = data;
                delete modItem.id;
                modItem.mod_id = modItem.mod.id;

                // push tool onto view
                array.push(modItem);
                $scope.model[label].push(modItem);
                $scope.mod_list[count_label] += 1;
                $scope.updateTabs();
                $scope.$emit('successMessage', 'Added ' + label + ' ' + add.name + ' successfully.');
            }, function(response) {
                var params = {label: 'Error adding ' + label, response: response};
                $scope.$emit('errorMessage', params);
            });
        }

        // reset tool search
        add.id = null;
        add.name = "";
    };

    // remove an item
    $scope.removeItem = function(array, index, type) {
        var item = array[index];
        if (item.id) {
            item._destroy = true;
        } else {
            array.splice(index, 1);
        }
        $scope.mod_list[type + "_count"] -= 1;
        $scope.updateTabs();
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
            delete $scope.originalModList;
            $scope.originalModList = angular.copy($scope.mod_list);
        }, function(response) {
            $scope.$emit('errorMessage', {label: 'Error saving mod list', response: response});
        });
    };

    $scope.discardChanges = function() {
        if (confirm("Are you sure you want to discard your changes?")) {
            $scope.mod_list = angular.copy($scope.originalModList);
            $scope.$broadcast('rebuildModels');
            $scope.updateTabs();
        }
    };
});