app.controller('modListDetailsController', function($scope, $rootScope, $q, $timeout, tagService) {
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

    $scope.toggleImportModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showImportModal = visible;
    };

    $scope.downloadModList = function() {
        var gameName = $rootScope.currentGame.nexus_name;
        var modListId = $scope.mod_list.id;
        window.location = 'modpicker://' + gameName + '/mod-list/' + modListId;
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

    // update the markdown editor
    $scope.updateEditor = function() {
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    $scope.$watch('editing', $scope.updateEditor);
    if ($scope.editing) $scope.updateEditor();
});