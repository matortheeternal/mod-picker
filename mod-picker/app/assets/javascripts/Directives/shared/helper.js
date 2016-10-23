app.directive('helper', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/helper.html',
        scope: false,
        controller: 'helperController'
    }
});

app.controller('helperController', function($scope, $rootScope) {
    $scope.toggleHelper = function() {
        $scope.showHelper = !$scope.showHelper;
    };

    $scope.helperDisabled = function() {
        return $rootScope.currentUser.settings.helper_disabled;
    };

    $scope.$on('enableHelper', function() {
        if (!$scope.helperDisabled()) {
            $scope.showHelper = true;
        }
    });

    $scope.$on('setHelperContext', function(helperContext) {
        $scope.helperContext = helperContext;
    });
});