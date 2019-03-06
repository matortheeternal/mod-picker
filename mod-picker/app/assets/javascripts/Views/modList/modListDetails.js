app.controller('modListDetailsController', function($scope, $rootScope, $q, $timeout, tagService, userService) {
    // inherited functions
    $scope.searchUsers = userService.searchUsers;

    // scope functions
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

    // update the markdown editor
    $scope.updateEditor = function() {
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    $scope.$watch('editing', $scope.updateEditor);
    if ($scope.editing) $scope.updateEditor();
});