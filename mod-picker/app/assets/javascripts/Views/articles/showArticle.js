app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.article', {
        templateUrl: '/resources/partials/articles/showArticle.html',
        controller: 'showArticleController',
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

app.controller('showArticleController', function($scope, $rootScope, $stateParams, article, contributionService, eventHandlerFactory) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // initialize variables
    $scope.article = article;
    $scope.pages = {
        comments: {}
    };
    $scope.errors = {};

    // set page title
    $scope.$emit('setPageTitle', article.title);

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope);

    // retrieves comments on the article
    $scope.retrieveComments = function(page) {
        var options = {
            sort: {
                column: 'submitted',
                direction: 'DESC'
            },
            page: page || 1
        };
        contributionService.retrieveComments('articles', $scope.article.id, options, $scope.pages.comments).then(function(data) {
            $scope.article.comments = data;
        }, function(response) {
            $scope.errors.comments = response;
        });
    };

    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    // retrieve the comments
    $scope.retrieveComments();
});
