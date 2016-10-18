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

    $scope.oldOptionChanged = function(option) {
        if (option.id) {
            var oldOption = $scope.oldOptions.find(function(oldOption) {
                return oldOption.id == option.id;
            });
            option.display_name = angular.copy(oldOption.display_name);
        } else {
            option.display_name = angular.copy(option.name);
        }
    }
});