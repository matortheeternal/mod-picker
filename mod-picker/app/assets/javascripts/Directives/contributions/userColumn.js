app.directive('userColumn', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/userColumn.html',
        scope: {
            user: '=',
            editors: '=?',
            index: '='
        },
        controller: 'userColumnController'
    };
});

app.controller('userColumnController', function($scope, $rootScope, $timeout) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // initialize local variables
    $scope.errors = {};

    $scope.target = $scope.user;

    $scope.toggleUserCard = function() {
        $scope.showUserCard = $scope.avatarHover;
    };

    $scope.mouseOverAvatar = function() {
        if (!$scope.avatarHover) {
            $scope.avatarHover = true;
            $timeout($scope.toggleUserCard, 300);
        }
    };

    $scope.mouseLeaveAvatar = function() {
        if ($scope.avatarHover) {
            $scope.avatarHover = false;
            $timeout($scope.toggleUserCard, 500);
        }
    };
});