app.directive('pageResults', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/browse/pageResults.html',
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

    $scope.scrollToTop = function() {
        smoothScroll({duration: 300});
    };

    $scope.$watch('pages', function(oldValue, newValue) {
        //only update the buttons if everything has been retrieved
        if(newValue.max && newValue.current) {
            $scope.pageRange();
        }
    }, true);
});
