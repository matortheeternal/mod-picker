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
    $scope.reducedText = $scope.text.reduceText($scope.numWords);
    $scope.expandable = $scope.text.wordCount() > $scope.numWords * 1.25 &&
        $scope.reducedText.length < $scope.text.length;

    $scope.expanded = false;
    $scope.toggleExpansion = function() {
        $scope.expanded = !$scope.expanded;
    };
});
