app.directive('readMore', function(spinnerFactory) {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/readMore.html',
        scope: {
            text: '=',
            numWords: '=words'
        },
        controller: 'readMoreController'
    };
});

app.controller('readMoreController', function($scope) {
    var wordCount = function(string) {
        return string.match(/(\S+)/g).length;
    };

    var reduceText = function(string) {
        var words = string.split(' ', $scope.numWords);
        return words.join(' ');
    };

    $scope.reducedText = reduceText($scope.text);
    $scope.expandable = wordCount($scope.text) > $scope.numWords * 1.25;

    $scope.expanded = false;
    $scope.toggleExpansion = function() {
        $scope.expanded = !$scope.expanded;
    };
});
