app.directive('article', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/article.html',
        controller: 'articleController',
        scope: {
            article: '=data',
            showFull: '=?'
        }
    };
});

app.controller('articleController', function($scope) {
    if (!$scope.showFull) {
        var reducedText = $scope.article.text_body.reduceText(50);
        if (reducedText.length < $scope.article.text_body.length) {
            reducedText += "\n\n...";
            $scope.article.text_body = reducedText;
            $scope.truncated = true;
        }
    }
});
