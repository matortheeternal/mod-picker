app.directive('pageResults', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/pageResults.html',
        controller: 'pageResultsController',
        scope: {
            pages: '=',
            data: '=',
            callback: '=',
            offset: '=?'
        }
    }
});

app.controller('pageResultsController', function($scope, $element, smoothScroll) {
    var pageDistance = 3;
    var scrollTarget = $scope.offset ? $element[0].parentElement : document.body;

    $scope.range = [];

    $scope.pageRange = function() {
        $scope.range = [];
        for (var i = 1; i <= $scope.pages.max; i++) {
            if ((i === 1) || (i === $scope.pages.max) ||
                (Math.abs($scope.pages.current - i) < pageDistance))
                $scope.range.push(i);
        }
    };

    $scope.scrollToTop = function() {
        smoothScroll(scrollTarget, {
            duration: 300,
            offset: $scope.offset
        });
    };

    $scope.$watch('pages.max', $scope.pageRange, true);
    $scope.$watch('pages.current', $scope.pageRange, true);
});
