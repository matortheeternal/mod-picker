app.directive('helper', function() {
    return {
        priority: 200,
        restrict: 'E',
        templateUrl: '/resources/directives/base/helper.html',
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
        return $rootScope.currentUser.settings.disable_helper;
    };

    $scope.$on('setHelpContexts', function(event, helpContexts) {
        $scope.helpContexts = helpContexts;
        $scope.trustContexts();
        $scope.hideHelper = ($scope.helpContexts.length == 0);
        if (!$scope.hideHelper && !$scope.helperDisabled()) {
            $scope.showHelper = true;
        }
    });
});