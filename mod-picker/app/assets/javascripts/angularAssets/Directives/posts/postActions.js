app.directive('postActions', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/posts/postActions.html',
        controller: 'postActionsController',
        scope: {
            target: '=',
            route: '=',
            correctable: '='
        }
    };
});

app.controller('postActionsController', function ($scope, modService) {
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
});