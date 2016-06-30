app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.edit', {
        templateUrl: '/resources/partials/showMod/edit.html',
        controller: 'editModController',
        url: '/mod/:modId/edit',
        resolve: {
            modObject: function(modService, $stateParams, $q) {
                var mod = $q.defer();
                modService.editMod($stateParams.modId).then(function(data) {
                    mod.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error editing mod.',
                        response: response,
                        stateName: "base.edit",
                        stateUrl: window.location.hash
                    };
                    mod.reject(errorObj);
                });
                return mod.promise;
            }
        }
    });
}]);

app.controller('editModController', function($scope, $state, currentUser, modObject, modService, tagService, errorService) {
    // get parent variables
    $scope.currentUser = currentUser;

    // initialize local variables
    $scope.permissions = angular.copy(currentUser.permissions);
    $scope.newTags = [];
    // error handling
    $scope.errors = {};

    /* load the mod object onto the view */
    // parse dates to date objects
    modObject.released = new Date(Date.parse(modObject.released));
    if (modObject.updated) {
        modObject.updated = new Date(Date.parse(modObject.updated));
    }
    // convert required mods into correct format
    modObject.requirements = [];
    modObject.required_mods.forEach(function(requirement) {
        modObject.requirements.push({
            required_id: requirement.required_mod.id,
            name: requirement.required_mod.name
        })
    });
    // convert categories into correct format
    modObject.categories = [];
    if (modObject.primary_category_id) {
        modObject.categories.push(modObject.primary_category_id);
    }
    if (modObject.secondary_category_id) {
        modObject.categories.push(modObject.secondary_category_id);
    }
    // put mod on scope
    $scope.mod = modObject;

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response, $scope.mod.id);
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

    //$scope.saveTags = function(updatedTags) {
    //    var action = $q.defer();
    //    tagService.updateModTags($scope.mod, updatedTags).then(function(data) {
    //        $scope.$emit('successMessage', 'Tags updated successfully.');
    //        action.resolve(data);
    //    }, function(response) {
    //        var params = {label: 'Error saving mod tags', response: response};
    //        $scope.$emit('errorMessage', params);
    //        action.reject(response);
    //    });
    //    return action.promise;
    //};
});