app.directive('userCard', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/userCard.html',
        scope: {
            user: '='
        },
        controller: 'userCardController'
    }
});

app.controller('userCardController', function($scope, $rootScope, userService) {
    // inherited variables
    $scope.permissions = $rootScope.permissions;

    // functions
    $scope.addRep = function() {
        if ($scope.added && !$scope.subtracted) return;
        $scope.added = true;
        userService.addRep($scope.user.id).then(function() {
            $scope.$emit("successMessage", "Increased "+$scope.user.username+"'s reputation by 5");
            $scope.user.reputation.overall += 5;
        }, function(response) {
            var params = {
                message: "Error increasing reputation",
                response: response
            };
            $scope.$emit("errorMessage", params);
        });
    };

    $scope.subtractRep = function() {
        if ($scope.subtracted && !$scope.added) return;
        $scope.subtracted = true;
        userService.subtractRep($scope.user.id).then(function() {
            $scope.$emit("successMessage", "Reduced "+$scope.user.username+"'s reputation by 5");
            $scope.user.reputation.overall -= 5;
        }, function(response) {
            var params = {
                message: "Error reducing reputation",
                response: response
            };
            $scope.$emit("errorMessage", params);
        });
    };

    $scope.changeRole = function(label, role) {
        if (!role) role = label;
        userService.changeRole($scope.user.id, role).then(function() {
            $scope.$emit("successMessage", label.capitalize() + " " + $scope.user.username);
            $scope.user.role = role;
        }, function(response) {
            var params = {
                message: "Error " + label.replace(/ing/g, "ed") + " user",
                response: response
            };
            $scope.$emit("errorMessage", params);
        });
    };

    $scope.restrictUser = function() {
        $scope.changeRole("restricted");
    };

    $scope.unrestrictUser = function() {
        $scope.changeRole("unrestricted", "user");
    };

    $scope.banUser = function() {
        $scope.changeRole("banned");
    };

    $scope.unbanUser = function() {
        $scope.changeRole("unbanned", "user");
    };
});