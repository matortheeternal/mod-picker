app.service('moderationActionsFactory', function(userService) {
    this.buildActions = function($scope) {
        $scope.repCounter = 0;

        // functions
        $scope.addRep = function() {
            if ($scope.repCounter > 0) return;
            $scope.repCounter += 1;
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
            if ($scope.repCounter < 0) return;
            $scope.repCounter -= 1;
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

        $scope.userRestricted = function() {
            return $scope.user.role === "restricted";
        };

        $scope.userBanned = function() {
            return $scope.user.role === "banned";
        };

        $scope.toggleRestrictUser = function() {
            if ($scope.userRestricted()) {
                $scope.changeRole("unrestricted", "user");
            } else {
                $scope.changeRole("restricted");
            }
        };

        $scope.toggleBanUser = function() {
            if ($scope.userBanned()) {
                $scope.changeRole("unbanned", "user");
            } else {
                $scope.changeRole("banned");
            }
        };
    };
});