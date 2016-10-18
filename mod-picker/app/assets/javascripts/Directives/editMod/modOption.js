app.directive('modOption', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modOption.html',
        scope: {
            option: '=',
            oldOptions: '='
        },
        controller: 'modOptionController'
    }
});

app.controller('modOptionController', function($scope, formUtils, assetUtils) {
    $scope.focusText = formUtils.focusText;

    $scope.findOldOption = function(optionId) {
        return $scope.oldOptions.find(function(oldOption) {
            return oldOption.id == optionId;
        });
    };

    $scope.oldOptionChanged = function() {
        var option = $scope.option;
        if (option.hasOwnProperty('id') && option.id !== null) {
            $scope.oldOption = $scope.findOldOption(option.id);
            option.display_name = angular.copy($scope.oldOption.display_name);
            $scope.loadExistingPlugins();
        } else {
            delete $scope.oldOption;
            option.id = undefined;
            option.display_name = angular.copy(option.name);
        }
        $scope.$emit('destroyUnusedOldOptions');
    };

    if ($scope.option.asset_file_paths && !$scope.option.nestedAssets) {
        $scope.option.nestedAssets = assetUtils.getNestedAssets($scope.option.asset_file_paths);
    }
});