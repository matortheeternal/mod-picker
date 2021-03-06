app.directive('readMore', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/readMore.html',
        scope: {
            text: '=',
            numWords: '=words'
        },
        controller: 'readMoreController'
    };
});

app.controller('readMoreController', function($scope) {
    $scope.expanded = false;
    $scope.toggleExpansion = function() {
        $scope.expanded = !$scope.expanded;
    };

    $scope.getReducedText = function() {
        $scope.reducedText = $scope.text.reduceText($scope.numWords);
        // TODO: add methods to contribution models to trim beginning/end whitespace
        // for text_body; current regex is to stop read more from showing up unnecessarily.
        $scope.text = $scope.text.trim();
        $scope.expandable = $scope.text.wordCount() > $scope.numWords * 1.25 &&
            $scope.reducedText.length < $scope.text.length;
    };

    $scope.$watch('text', $scope.getReducedText);
    $scope.getReducedText();
});
