/**
 * Created by r79 on 2/11/2016.
 */

app.directive('linkNexusAccount', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/linkNexusAccount.html',
        controller: 'linkNexusAccountController',
        scope: {
            bio: '='
        }
    }
});

// TODO: Resolve redundancy between this and linkLoverAccountController
app.controller('linkNexusAccountController', function ($scope) {
    $scope.validateUrl = function() {
        var site = sitesFactory.getSite(sitesFactory.sites, "Nexus Mods");
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
        userSettingsService.verifyAccount("nexus").then(function(data) {
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
