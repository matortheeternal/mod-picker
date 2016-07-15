app.directive('readMore', function(spinnerFactory) {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/readMore.html',
        scope: {
            text: '='
        },
        controller: 'readMoreController'
    };
});

app.controller('readMoreController', function($scope) {
    wordCount = function(string) {
        return string.match(/(\S+)/g).length;
    };

    //returns just the first 50 words of a string
    reduceText = function(string) {
        words = string.split(' ', 50);
        return words.join(' ');
    };

    $scope.reducedText = reduceText($scope.text);
    $scope.expandable = wordCount($scope.text) > 50;

    $scope.expanded = false;
    $scope.switchExpansion = function() {
        $scope.expanded = !$scope.expanded;
    };
});
