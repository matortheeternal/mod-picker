app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.edit', {
        templateUrl: '/resources/partials/edit.html',
        controller: 'editModController',
        url: '/edit/:modId',
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
    $scope.mod = modObject.mod;
    $scope.currentUser = currentUser;

    // initialize local variables
    $scope.tags = [];
    $scope.newTags = [];
    // error handling
    $scope.errors = {};

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