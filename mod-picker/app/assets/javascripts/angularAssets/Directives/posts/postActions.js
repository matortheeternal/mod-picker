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

app.controller('postActionsController', function ($scope, $timeout, modService) {
    $scope.helpfulMark = function(helpful) {
        if ($scope.target.helpful == helpful) {
            modService.helpfulMark($scope.route, $scope.target.id).then(function (data) {
                if (data.status == "ok") {
                    delete $scope.target.helpful;
                }
            });
        } else {
            modService.helpfulMark($scope.route, $scope.target.id, helpful).then(function (data) {
                if (data.status == "ok") {
                    $scope.target.helpful = helpful;
                }
            });
        }
    };

    $scope.blurDropdown = function() {
        // we have to use a timeout for hiding the dropdown because
        // otherwise we would hide it before the click event on a result
        // went through
        $timeout(function() {
            $scope.showDropdown = false;
        }, 100);
    };
});