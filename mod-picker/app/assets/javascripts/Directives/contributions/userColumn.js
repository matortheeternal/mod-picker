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

    // setting permissions to NOT inherit from currentUser as its currently unnecessary
    $scope.permissions = {};

    // initialize local variables
    $scope.errors = {};
    $scope.report = {
        reportable_id: $scope.user.id,
        reportable_type: 'User'
    };
    $scope.modelObj = {
        name: "User",
        label: "User",
        route: "users"
    }

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

    // reports permission
    $scope.permissions.canReport = $scope.currentUser || false;

    // report modal state
    $scope.toggleReportModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showReportModal = visible;
    };
});