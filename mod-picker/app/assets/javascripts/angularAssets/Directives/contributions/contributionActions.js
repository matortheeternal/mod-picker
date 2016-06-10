app.directive('contributionActions', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/contributionActions.html',
        controller: 'contributionActionsController',
        scope: {
            target: '=',
            index: '=',
            route: '=',
            user: '=',
            correctable: '=?', // default true
            approveable: '=?', // default true
            agreeable: '=?',   // default undefined
            edit: '=?',        // default undefined
            hasHistory: '=?'   // default undefined
        }
    };
});

app.controller('contributionActionsController', function ($scope, $timeout, contributionService) {
    // correctable should have a default value of true
    $scope.correctable = angular.isDefined($scope.correctable) ? $scope.correctable : true;
    // approveable should have a default value of true
    $scope.approveable = angular.isDefined($scope.approveable) ? $scope.approveable : true;

    // this is a direct link to the contribution to be displayed in the get link modal
    $scope.shareLink = window.location.href + '/' + $scope.route + '/' + $scope.target.id;
    // this is a computed label for the contribution (we may want to use a switch in the future)
    $scope.label = $scope.route.split('_').join(' ').slice(0, -1);
    // this is the report object
    $scope.report = {};

    $scope.toggleLinkModal = function(visible) {
        $scope.showLinkModal = visible;
    };

    $scope.toggleReportModal = function(visible) {
        $scope.showReportModal = visible;
    };

    $scope.updateHelpfulCounter = function(helpful, increment) {
        var value = increment ? 1 : -1;
        if (helpful) {
            $scope.target.helpful_count += value;
        } else {
            $scope.target.not_helpful_count += value;
        }
    };

    $scope.helpfulMark = function(helpful) {
        if ($scope.target.helpful == helpful) {
            contributionService.helpfulMark($scope.route, $scope.target.id).then(function (data) {
                if (data.status == "ok") {
                    delete $scope.target.helpful;
                    $scope.updateHelpfulCounter(helpful, false);
                }
            });
        } else {
            contributionService.helpfulMark($scope.route, $scope.target.id, helpful).then(function (data) {
                if (data.status == "ok") {
                    if ($scope.target.helpful == !helpful) {
                        $scope.updateHelpfulCounter(!helpful, false);
                    }
                    $scope.target.helpful = helpful;
                    $scope.updateHelpfulCounter(helpful, true);
                }
            });
        }
    };

    $scope.updateAgreeCounter = function(agree, increment) {
        var value = increment ? 1 : -1;
        if (agree) {
            $scope.target.agree_count += value;
        } else {
            $scope.target.disagree_count += value;
        }
    };

    $scope.agreementMark = function(agree) {
        if ($scope.target.agreement == agree) {
            contributionService.agreementMark($scope.route, $scope.target.id).then(function (data) {
                if (data.status == "ok") {
                    delete $scope.target.agreement;
                    $scope.updateAgreeCounter(agree, false);
                }
            });
        } else {
            contributionService.agreementMark($scope.route, $scope.target.id, agree).then(function (data) {
                if (data.status == "ok") {
                    if ($scope.target.agreement == !agree) {
                        $scope.updateAgreeCounter(!agree, false);
                    }
                    $scope.target.agreement = agree;
                    $scope.updateAgreeCounter(agree, true);
                }
            });
        }
    };

    $scope.approve = function(approved) {
        contributionService.approve($scope.route, $scope.target.id, approved).then(function (data) {
            if (data.status == "ok") {
                $scope.target.approved = approved;
            }
        });
    };

    $scope.hide = function(hidden) {
        contributionService.hide($scope.route, $scope.target.id, hidden).then(function (data) {
            if (data.status == "ok") {
                $scope.target.hidden = hidden;
            }
        });
    };

    $scope.blurDropdown = function() {
        // we have to use a timeout for hiding the dropdown because
        // otherwise we would hide it before the click event on a result
        // went through
        $timeout(function() {
            $scope.showDropdown = false;
        }, 100);
    };

    $scope.setPermissions = function() {
        // permissions helper variables
        var isAdmin = $scope.user && $scope.user.role === 'admin';
        var isModerator = $scope.user && $scope.user.role === 'moderator';
        var isSubmitter = $scope.user && $scope.user.id === $scope.target.user.id;
        // set up permissions
        $scope.canReport = $scope.user || false;
        $scope.canEdit = isAdmin || isModerator || isSubmitter;
        $scope.canApprove = isAdmin || isModerator;
        $scope.canHide = isAdmin || isModerator;
    };

    // watch user so if we get the user object after rendering actions
    // we can re-render them correctly per the user's permissions
    $scope.$watch('user', $scope.setPermissions, true);
});