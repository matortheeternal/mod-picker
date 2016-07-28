app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.article', {
        templateUrl: '/resources/partials/articles/article.html',
        controller: 'articleController',
        url: '/article/:articleId',
        resolve: {
            article: function(articleService, $stateParams, $q) {
                var article = $q.defer();
                articleService.retrieveArticle($stateParams.articleId).then(function(articleData) {
                    article.resolve(articleData);
                }, function(response) {
                    this.self.errorObj = {
                        text: 'Error retrieving article.',
                        response: response,
                        stateName: "base.article",
                        stateUrl: window.location.hash
                    };
                    article.reject();
                });
                return article.promise;
            }
        }
    });
}]);

app.controller('articleController', function($scope, $stateParams, article) {
    $scope.article = article;
});
