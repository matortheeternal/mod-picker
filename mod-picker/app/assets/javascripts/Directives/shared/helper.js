app.directive('helper', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/helper.html',
        scope: false,
        controller: 'helperController'
    }
});

app.controller('helperController', function($scope, $rootScope, $sce) {
    $scope.trustContexts = function() {
        $scope.helpContexts = $scope.helpContexts.map(function(context) {
            return $sce.trustAsHtml(context);
        });
    };

    $scope.removeContext = function($index) {
        $scope.helpContexts.splice($index, 1);
    };

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

    $scope.$on('setHelpContexts', function(event, helpContexts) {
        $scope.helpContexts = helpContexts;
        $scope.trustContexts();
        $scope.helperDisabled = ($scope.helpContexts.length == 0);
        if ($scope.helperDisabled) $scope.showHelper = false;
    });
});