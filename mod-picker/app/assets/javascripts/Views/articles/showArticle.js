// redirect for the old url format of /article/:articleId
app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.old-article', {
        url: '/article/:articleId',
        redirectTo: 'base.article'
    })
}]);

app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.article', {
        templateUrl: '/resources/partials/articles/showArticle.html',
        controller: 'showArticleController',
        url: '/articles/{articleId:int}',
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
                        stateUrl: window.location.href
                    };
                    article.reject();
                });
                return article.promise;
            }
        }
    });
}]);

app.controller('showArticleController', function($scope, $rootScope, $stateParams, article, contributionService, helpFactory, eventHandlerFactory) {
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

    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.article]);

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
