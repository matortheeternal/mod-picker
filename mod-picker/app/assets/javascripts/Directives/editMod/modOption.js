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

app.controller('modOptionController', function($scope, formUtils) {
    $scope.focusText = formUtils.focusText;

    $scope.findOldOption = function(optionId) {
        return $scope.oldOptions.find(function(oldOption) {
            return oldOption.id == optionId;
        });
    };

    $scope.oldOptionChanged = function(option) {
        if (option.hasOwnProperty('id') && option.id !== null) {
            var oldOption = $scope.findOldOption(option.id);
            option.display_name = angular.copy(oldOption.display_name);
        } else {
            option.id = undefined;
            option.display_name = angular.copy(option.name);
        }
        $scope.$emit('destroyUnusedOldOptions');
    }
});