app.controller('modListDetailsController', function($scope, $q, $timeout, tagService) {
    $scope.toggleExportDropdown = function($event) {
        $scope.showExportDropdown = !$scope.showExportDropdown;
        if (!$scope.showExportDropdown) {
            $event.currentTarget.blur();
        }
    };

    $scope.blurExportDropdown = function() {
        $timeout(function() {
            $scope.showExportDropdown = false;
        }, 250);
    };

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