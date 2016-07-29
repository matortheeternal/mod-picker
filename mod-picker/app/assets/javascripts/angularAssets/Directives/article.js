app.directive('article', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/article.html',
        controller: 'articleController',
        scope: {
            article: '=data',
            condensed: '=?'
        }
    };
});

app.controller('articleController', function($scope) {
    if ($scope.condensed) {
        var words = $scope.article.text_body.split(' ', 50);
        $scope.article.text_body = words.join(' ');
        $scope.article.text_body += "...";
    }
});
