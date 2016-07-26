app.directive('pageResults', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/pageResults.html',
        controller: 'pageResultsController',
        scope: {
            pages: '=',
            data: '=',
            callback: '='
        }
    }
});

app.controller('pageResultsController', function($scope, smoothScroll) {
    var pageDistance = 3;
    $scope.range = [];

    $scope.pageRange = function() {
        $scope.range = [];
        for (var i = 1; i <= $scope.pages.max; i++) {
            if ((i === 1) || (i == $scope.pages.max) ||
                (Math.abs($scope.pages.current - i) < pageDistance))
                $scope.range.push(i);
        }
    };

    $scope.scrollTo = function() {
        smoothScroll({duration: 300});
    };

    $scope.$watch('pages.max', $scope.pageRange);
    $scope.$watch('pages.current', $scope.pageRange);
});
