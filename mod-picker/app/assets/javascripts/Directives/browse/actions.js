app.directive('actions', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/actions.html',
        controller: 'actionsController',
        scope: false
    }
});

app.controller('actionsController', function($scope, $timeout) {
    $scope.toggleDropdown = function(action, item) {
        if (!$scope.resolve(action.disabled, item)) {
            item[action.key] = !item[action.key];
        }
    };

    $scope.blurDropdown = function(action, item) {
        $timeout(function() {
            item[action.key] = false;
        }, 100);
    };
    $scope.actionClick = function(action, item) {
        if (action.items) {
            $scope.toggleDropdown(action, item);
        } else {
            $scope.resolve(action.execute, item);
        }
    };

    $scope.actionBlur = function(action, item) {
        if (action.items) {
            $scope.blurDropdown(action, item);
        }
    };
});