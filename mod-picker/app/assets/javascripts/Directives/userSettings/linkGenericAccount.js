app.directive('linkGenericAccount', function() {
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

app.controller('linkGenericAccountController', function($scope, $timeout, userSettingsService, sitesFactory, eventHandlerFactory, formUtils) {
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
            if ($scope.bio.hasOwnProperty(fullKey)) {
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

    $scope.fixUrl = function(userUrl) {
        if (!$scope.site.badUserUrlFormat) return userUrl;
        var match = userUrl.match($scope.site.badUserUrlFormat);
        if (match) {
            var idClause = match[2].split('-')[0];
            return $scope.site.baseUserUrlFormat + idClause;
        }
        return userUrl;
    };

    $scope.validateUrl = function() {
        var userUrl = $scope.fixUrl($scope.bio[$scope.userUrlKey]);
        var match  = userUrl.match($scope.site.userUrlFormat);
        $scope.urlValid = match !== null;
    };

    $scope.verifyUser = function() {
        // exit if we're waiting for the next request or the user has been verified
        if ($scope.bio.waiting || $scope.bio.verified) {
            return;
        }

        // exit if the url is invalid
        var userUrl = $scope.fixUrl($scope.bio[$scope.userUrlKey]);
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
                    text: 'Failed to verify account. You can try again in 30 seconds.'
                };
                $scope.$emit('modalCustomMessage', params);
            } else {
                $scope.$emit('successMessage', $scope.site.label + ' account verified!');
                $scope.bio = data.bio;
                $scope.bio[$scope.verifiedKey] = true;
                $scope.initSiteVars();
                $scope.toggleModal();
            }
        }, function(response) {
            $scope.bio.verifying = false;
            var params = { label: 'Error verifying account', response: response };
            $scope.$emit('modalErrorMessage', params);
        });
        $timeout(function() {
            $scope.bio.waiting = false;
        }, 30000);
    };
});
