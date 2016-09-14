app.directive('report', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/report.html',
        scope: {
            report: '=data',
            showFull: '=?',
            reportable: '=reportable'
        },
        controller: 'reportController',
    };
});

app.controller('reportController', function($scope) {
    angular.inherit($scope, 'report');
    $scope.testingData = 'foobar';

    console.log('wowowowowow');
    // if (!$scope.showFull) {
    //     var reducedText = $scope.article.text_body.reduceText(50);
    //     if (reducedText.length < $scope.article.text_body.length) {
    //         reducedText += "\n\n...";
    //         $scope.article.text_body = reducedText;
    //         $scope.truncated = true;
    //     }
    // }
});
