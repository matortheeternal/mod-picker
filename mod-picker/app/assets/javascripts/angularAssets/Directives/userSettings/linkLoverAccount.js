app.directive('linkLoverAccount', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/linkLoverAccount.html',
        controller: 'linkLoverAccountController',
        scope: {
            bio: '='
        }
    }
});

app.controller('linkLoverAccountController', function ($scope, $timeout, userSettingsService, sitesFactory) {
    $scope.validateUrl = function() {
        var site = sitesFactory.getSite(sitesFactory.sites, "Lover's Lab");
        $scope.urlValid = $scope.userUrl.match(site.userUrlFormat);
    };

    $scope.verifyUser = function() {
        // exit if the url is invalid, we're waiting for the next request,
        // or the user has been verified
        if (!$scope.urlValid || waiting || verified) {
            return;
        }

        $scope.errors = [];
        $scope.waiting = true;
        userSettingsService.verifyAccount("lab").then(function(data) {
            $scope.verified = data.verified;
            if (!data.verified) {
                $scope.errors.push({ message: "Failed to verify account.  You can try again in 30 seconds." });
            }
        });
        $timeout(function() {
            $scope.waiting = false;
        }, 30000);
    };
});
