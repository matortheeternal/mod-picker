app.directive('linkGenericAccount', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/userSettings/linkGenericAccount.html',
        controller: 'linkGenericAccountController',
        scope: {
            bio: '=',
            siteLabel: '@',
            siteKey: '@'
        }
    }
});

app.controller('linkGenericAccountController', function ($scope, $timeout, userSettingsService, sitesFactory, eventHandlerFactory, formUtils) {
    // initialize variables
    $scope.showModal = false;
    $scope.userUrlKey = $scope.siteKey + '_user_url';
    $scope.verifiedKey = $scope.siteKey + '_verified';
    $scope.site = sitesFactory.getSite($scope.siteLabel);
    $scope.linkSteps = sitesFactory.getLinkSteps($scope.siteLabel);

    // extended initialization using generic keys
    $scope.initSiteVars = function() {
        var keys = ['username', 'submissions_count', 'followers_count', 'date_joined', 'posts_count', 'verification_token'];
        keys.forEach(function(dataKey) {
            var fullKey = $scope.siteKey + '_' + dataKey;
            if ($scope.bio[fullKey]) {
                $scope[dataKey] = $scope.bio[fullKey];
            }
        });
    };

    // init site vars when we directive loads
    $scope.initSiteVars();

    // inherited functions
    $scope.focusText = formUtils.focusText;
    eventHandlerFactory.buildModalMessageHandlers($scope, true);

    // normal functions
    $scope.toggleModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showModal = visible;
    };

    $scope.validateUrl = function() {
        var userUrl = $scope.bio[$scope.userUrlKey];
        var match  = userUrl.match($scope.site.userUrlFormat);
        $scope.urlValid = match !== null;
    };

    $scope.verifyUser = function() {
        // exit if we're waiting for the next request or the user has been verified
        if ($scope.bio.waiting || $scope.bio.verified) {
            return;
        }

        // exit if the url is invalid
        var userUrl = $scope.bio[$scope.userUrlKey];
        var match  = userUrl.match($scope.site.userUrlFormat);
        if (!match) {
            return;
        }

        $scope.bio.waiting = true;
        $scope.bio.verifying = true;
        var user_path = match[$scope.site.userIndex];
        userSettingsService.verifyAccount($scope.siteLabel, user_path).then(function(data) {
            $scope.bio.verifying = false;
            if (!data.verified) {
                var params = {
                    type: 'error',
                    message: 'Failed to verify account. You can try again in 30 seconds.'
                };
                $scope.$emit('modalCustomMessage', params);
            } else {
                $scope.$emit('successMessage', $scope.site.label + ' account verified!');
                $scope.bio = data.bio;
                $scope.bio[$scope.verifiedKey] = true;
                $scope.initSiteVars();
                $scope.showModal = false;
            }
        }, function() {
            $scope.bio.verifying = false;
            var params = { type: 'error', message: 'Error verifying account.' };
            $scope.$emit('modalCustomMessage', params);
        });
        $timeout(function() {
            $scope.bio.waiting = false;
        }, 30000);
    };
});
