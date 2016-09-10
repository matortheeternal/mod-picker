app.directive('report', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/report.html',
        controller: 'reportController',
        scope: {
            report: '=data',
            showFull: '=?'
        }
    };
});

app.controller('reportController', function($scope) {
    // if (!$scope.showFull) {
    //     var reducedText = $scope.article.text_body.reduceText(50);
    //     if (reducedText.length < $scope.article.text_body.length) {
    //         reducedText += "\n\n...";
    //         $scope.article.text_body = reducedText;
    //         $scope.truncated = true;
    //     }
    // }
});
