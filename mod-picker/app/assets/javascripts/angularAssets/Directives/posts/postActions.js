app.directive('postActions', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/posts/postActions.html',
        controller: 'postActionsController',
        scope: {
            target: '=',
            index: '=',
            route: '=',
            correctable: '=',
            user: '='
        }
    };
});

app.controller('postActionsController', function ($scope, $timeout, contributionService) {
    $scope.helpfulMark = function(helpful) {
        if ($scope.target.helpful == helpful) {
            contributionService.helpfulMark($scope.route, $scope.target.id).then(function (data) {
                if (data.status == "ok") {
                    delete $scope.target.helpful;
                }
            });
        } else {
            contributionService.helpfulMark($scope.route, $scope.target.id, helpful).then(function (data) {
                if (data.status == "ok") {
                    $scope.target.helpful = helpful;
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
        contributionService.approve($scope.route, $scope.target.id, hidden).then(function (data) {
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