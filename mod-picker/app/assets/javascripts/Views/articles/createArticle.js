app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.create-article', {
        templateUrl: '/resources/partials/articles/createArticle.html',
        controller: 'createArticleController',
        url: '/articles/submit',
        resolve: {
            article: function($q, articleService) {
                var article = $q.defer();
                articleService.newArticle().then(function(data) {
                    article.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error starting new article.',
                        response: response,
                        stateName: "base.create-article",
                        stateUrl: window.location.href
                    };
                    article.reject(errorObj);
                });
                return article.promise;
            }
        }
    });
}]);

app.controller('createArticleController', function($scope, $rootScope, $state, $stateParams, article, articleService, helpFactory, eventHandlerFactory) {
    // set up local variables
    $scope.article = article;
    $scope.defaultSrc = '/articles/Default-big.png';
    $scope.imageSizes = [
        { label: 'big', size: 300 },
        { label: 'medium', size: 210 },
        { label: 'small', size: 100 }
    ];
    $scope.image = {
        sizes: [
            { label: 'big', src: $scope.defaultSrc }
        ]
    };

    // set page title
    $scope.$emit('setPageTitle', 'Create Article');

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope);

    // set help context
    helpFactory.setHelpContexts($scope, []);

    // returns true if the article is valid
    $scope.articleValid = function() {
        var article = $scope.article;
        return article.title && article.text_body;
    };

    $scope.submit = function() {
        // return if article is invalid
        if (!$scope.articleValid()) {
            return;
        }

        // set up success handler to reduce repetition
        $scope.startSubmission("Submitting article...");
        articleService.submitArticle($scope.article).then(function(data) {
            if ($scope.image.changed) {
                $scope.submitImage(data.id);
            } else {
                $scope.submissionSuccess("Article submitted successfully.", [
                    { 
                        link: "articles/" + data.id,
                        linkLabel: "view the new article." 
                    },
                    {
                        link: "articles",
                        linkLabel: "return to the articles index page."
                    }
                ]);
            }
        }, function(response) {
            $scope.submissionError("There were errors submitting the article.", response);
        });
    };

    $scope.submitImage = function(articleId) {
        articleService.submitImage(articleId, $scope.image.sizes).then(function() {
            $scope.submissionSuccess("Article submitted successfully.", [
                { 
                    link: "articles/" + articleId,
                    linkLabel: "view the new article." 
                },
                { 
                    link: "home",
                    linkLabel: "return to the home page."
                }
            ]);
        }, function() {
            $scope.submissionSuccess("Article submitted successfully, image submission failed.", [
                { 
                    link: "articles/" + articleId,
                    linkLabel: "view the new article." 
                },
                {
                    link: "home",
                    linkLabel: "return to the home page."
                }
            ]);
        });
    };
});
