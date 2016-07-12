/**
 * Created by ThreeTen on 3/26/2016.
 */
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.modlist', {
        templateUrl: '/resources/partials/modList/modList.html',
        controller: 'modlistController',
        url: '/mod-list/:modListId',
        redirectTo: 'base.modlist.Details',
        resolve: {
            modListObject: function(modListService, $stateParams, $q) {
                var modList = $q.defer();
                modListService.retrieveModList($stateParams.modListId).then(function(data) {
                    modList.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error retrieving mod list.',
                        response: response,
                        stateName: "base.mod-list",
                        stateUrl: window.location.hash
                    };
                    modList.reject(errorObj);
                });
                return modList.promise;
            }
        }
    }).state('base.modlist.Details', {
        templateUrl: '/resources/partials/modList/details.html',
        controller: 'modlistDetailsController',
        url: '/details'
    }).state('base.modlist.Tools', {
        templateUrl: '/resources/partials/modList/tools.html',
        controller: 'modlistToolsController',
        url: '/tools'
    }).state('base.modlist.Mods', {
        templateUrl: '/resources/partials/modList/mods.html',
        controller: 'modlistModsController',
        url: '/mods'
    }).state('base.modlist.Plugins', {
        templateUrl: '/resources/partials/modList/plugins.html',
        controller: 'modlistPluginsController',
        url: '/plugins'
    }).state('base.modlist.Config', {
        templateUrl: '/resources/partials/modList/config.html',
        controller: 'modlistConfigController',
        url: '/config'
    }).state('base.modlist.Comments', {
        templateUrl: '/resources/partials/modList/comments.html',
        controller: 'modlistCommentsController',
        url: '/comments'
    })
}]);

app.controller('modlistController', function($scope, $log, $stateParams, $timeout, currentUser, modListObject, modListService) {
    // get parent variables
    $scope.modlist = modListObject;
    $scope.currentUser = currentUser;

	// initialize local variables
	$scope.bIsEditing = false;
    $scope.tabs = [
        { name: 'Details' },
        { name: 'Tools' },
        { name: 'Mods' },
        { name: 'Plugins' },
        { name: 'Config' },
        { name: 'Comments' }
    ];
    $scope.statusIcons = {
        planned: 'fa-pencil-square-o',
        "under construction": 'fa-wrench',
        testing: 'fa-cogs',
        complete: 'fa-check'
    };
    $scope.visibilityIcons = {
        visibility_private: 'fa-eye-slash',
        visibility_unlisted: 'fa-share-alt',
        visibility_public: 'fa-eye'
    };

    // a copy is created so the original permissions object is never changed
    $scope.permissions = angular.copy(currentUser.permissions);
    // setting up the canManage permission
    var isAuthor = $scope.modlist.submitter.id == $scope.currentUser.id;
    $scope.permissions.canManage = $scope.permissions.canModerate || isAuthor;

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response, $scope.modlist.id);
        errors.forEach(function(error) {
            $scope.$broadcast('message', error);
        });
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display success message
    $scope.$on('successMessage', function(event, text) {
        var successMessage = {type: "success", text: text};
        $scope.$broadcast('message', successMessage);
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    $scope.toggleEditing = function() {
        $scope.editing = !$scope.editing;
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
