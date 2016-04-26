app.directive('pageResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/pageResults.html',
        controller: 'pageResultsController',
        scope: false
    }
});

app.controller('pageResultsController', function($scope) {
    var pageDistance = 3;

    $scope.pageRange = function() {
        if (!$scope.pages.max) {
            return [];
        }
        var a = [];
        for (var i = 1; i <= $scope.pages.max; i++) {
            if ((i === 1) || (i == $scope.pages.max) ||
                (Math.abs($scope.pages.current - i) < pageDistance))
                a.push(i);
        }
        return a;
    }
});