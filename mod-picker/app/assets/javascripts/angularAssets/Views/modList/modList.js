/**
 * Created by ThreeTen on 3/26/2016.
 */
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.mod-list', {
        templateUrl: '/resources/partials/modList/modList.html',
        controller: 'modlistController',
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
        controller: 'modlistDetailsController',
        url: '/details'
    }).state('base.mod-list.Tools', {
        templateUrl: '/resources/partials/modList/tools.html',
        controller: 'modlistToolsController',
        url: '/tools'
    }).state('base.mod-list.Mods', {
        templateUrl: '/resources/partials/modList/mods.html',
        controller: 'modlistModsController',
        url: '/mods'
    }).state('base.mod-list.Plugins', {
        templateUrl: '/resources/partials/modList/plugins.html',
        controller: 'modlistPluginsController',
        url: '/plugins'
    }).state('base.mod-list.Config', {
        templateUrl: '/resources/partials/modList/config.html',
        controller: 'modlistConfigController',
        url: '/config'
    }).state('base.mod-list.Comments', {
        templateUrl: '/resources/partials/modList/comments.html',
        controller: 'modlistCommentsController',
        url: '/comments'
    })
}]);

app.controller('modlistController', function($scope, $log, $stateParams, $timeout, currentUser, modListObject, modListService) {
    // get parent variables
    $scope.mod_list = modListObject.mod_list;
    $scope.currentUser = currentUser;

	// initialize local variables
    $scope.tabs = [
        { name: 'Details' },
        { name: 'Tools' },
        { name: 'Mods' },
        { name: 'Plugins' },
        { name: 'Config' },
        { name: 'Comments' }
    ];
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

    $scope.toggleEditing = function() {
        $scope.editing = !$scope.editing;
        if (!$scope.activeModList) {
            $scope.activeModList = angular.copy($scope.mod_list);
        }
    };

    // MOD LIST EDITING LOGIC
    $scope.saveChanges = function() {
        // get changed mod fields
        var modListDiff = getDifferentProperties($scope.activeModList, $scope.mod_list);
        modListDiff.id = $scope.mod_list.id;

        modListService.updateModList(modListDiff).then(function() {
            $scope.$emit('successMessage', 'Mod list saved successfully.');
            $scope.mod_list = angular.copy($scope.activeModList);
        }, function(response) {
            $scope.$emit('errorMessage', {label: 'Error saving mod list', response: response});
        });
    };

    $scope.discardChanges = function() {
        if (confirm("Are you sure you want to discard your changes?")) {
            $scope.activeModList = angular.copy($scope.mod_list);
        }
    };
});

app.controller('modlistDetailsController', function($scope) {

});

app.controller('modlistToolsController', function($scope) {

});

app.controller('modlistModsController', function($scope) {

});

app.controller('modlistPluginsController', function($scope) {

});

app.controller('modlistConfigController', function($scope) {

});

app.controller('modlistCommentsController', function($scope) {

});
