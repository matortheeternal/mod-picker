app.directive('linkGenericAccount', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/linkGenericAccount.html',
        controller: 'linkGenericAccountController',
        scope: {
            bio: '=',
            siteLabel: '=',
            siteUsername: '=',
            sitePostsCount: '=',
            siteDateJoined: '=',
            siteSubmissionsCount: '=',
            siteFollowersCount: '=',
            siteVerificationToken: '='
        }
    }
});

app.controller('linkGenericAccountController', function ($scope, $timeout, userSettingsService, sitesFactory) {
    $scope.showModal = false;
    $scope.waiting = false;
    $scope.verified = false;
    $scope.site = sitesFactory.getSite($scope.siteLabel);

    $scope.focusText = function($event) {
        $event.target.select();
    };

    $scope.toggleModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showModal = !$scope.showModal;
    };

    $scope.validateUrl = function() {
        var match  = $scope.userUrl.match($scope.site.userUrlFormat);
        $scope.urlValid = match !== null;
    };

    $scope.verifyUser = function() {
        // exit if we're waiting for the next request or the user has been verified
        if ($scope.waiting || $scope.verified) {
            return;
        }

        // exit if the url is invalid
        var match  = $scope.userUrl.match($scope.site.userUrlFormat);
        if (!match) {
            return;
        }

        $scope.errors = [];
        $scope.waiting = true;
        var user_path = match[$scope.site.userIndex];
        userSettingsService.verifyAccount($scope.siteLabel, user_path).then(function(data) {
            $scope.verified = data.verified;
            if (!data.verified) {
                $scope.errors.push({ message: "Failed to verify account. You can try again in 30 seconds." });
            } else {
                $scope.bio = data.bio;
            }
        });
        $timeout(function() {
            $scope.waiting = false;
        }, 30000);
    };
});
