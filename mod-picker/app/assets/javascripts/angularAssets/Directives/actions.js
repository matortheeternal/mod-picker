app.directive('actions', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/actions.html',
        controller: 'actionsController',
        scope: false
    }
});

app.controller('actionsController', function($scope, $timeout) {
    $scope.toggleDropdown = function(item, action) {
        if (!$scope.resolve(action.disabled, item)) {
            item[action.key] = !item[action.key];
        }
    };

    $scope.blurDropdown = function(item, action) {
        $timeout(function() {
            item[action.key] = false;
        }, 100);
    };
});