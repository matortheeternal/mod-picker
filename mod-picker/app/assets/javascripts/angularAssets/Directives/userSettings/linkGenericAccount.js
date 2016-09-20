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

app.controller('linkGenericAccountController', function ($scope, $timeout, userSettingsService, sitesFactory, formUtils) {
    // initialize variables
    $scope.showModal = false;
    $scope.waiting = false;
    $scope.verified = false;
    $scope.userUrlKey = $scope.siteKey + '_user_url';
    $scope.site = sitesFactory.getSite($scope.siteLabel);
    $scope.linkSteps = sitesFactory.getLinkSteps($scope.siteLabel);

    // extended initialization using generic keys
    $scope.initSiteVar = function(dataKey) {
        var fullKey = $scope.siteKey + '_' + dataKey;
        if ($scope.bio[fullKey]) {
            $scope[dataKey] = $scope.bio[fullKey];
        }
    };
    $scope.initSiteVar('username');
    $scope.initSiteVar('submissions_count');
    $scope.initSiteVar('followers_count');
    $scope.initSiteVar('date_joined');
    $scope.initSiteVar('posts_count');
    $scope.initSiteVar('verification_token');
    if (!$scope.bio[$scope.userUrlKey]) $scope.bio[$scope.userUrlKey] = "";

    // inherited functions
    $scope.focusText = formUtils.focusText;

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
        if ($scope.waiting || $scope.verified) {
            return;
        }

        // exit if the url is invalid
        var userUrl = $scope.bio[$scope.userUrlKey];
        var match  = userUrl.match($scope.site.userUrlFormat);
        if (!match) {
            return;
        }

        $scope.waiting = true;
        var user_path = match[$scope.site.userIndex];
        userSettingsService.verifyAccount($scope.siteLabel, user_path).then(function(data) {
            $scope.verified = data.verified;
            if (!data.verified) {
                $scope.$emit('modalMessage', { type: 'error', message: 'Failed to verify account. You can try again in 30 seconds.' });
            } else {
                $scope.$emit('modalMessage', { type: 'success', message: 'Account verified!' });
                $scope.bio = data.bio;
            }
        }, function() {
            $scope.$emit('modalMessage', { type: 'error', message: 'Error verifying account.' });
        });
        $timeout(function() {
            $scope.waiting = false;
        }, 30000);
    };
});
