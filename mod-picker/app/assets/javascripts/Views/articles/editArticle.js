// redirect for the old url format of /article/:articleId/edit
app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.old-edit-article', {
        url: '/article/:articleId/edit',
        redirectTo: 'base.edit-article'
    })
}]);

app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.edit-article', {
        templateUrl: '/resources/partials/articles/editArticle.html',
        controller: 'editArticleController',
        url: '/articles/:articleId/edit',
        resolve: {
            article: function(articleService, $stateParams, $q) {
                var article = $q.defer();
                articleService.editArticle($stateParams.articleId).then(function(data) {
                    article.resolve(data);
                }, function(response) {
                    this.self.errorObj = {
                        text: 'Error editing article.',
                        response: response,
                        stateName: "base.edit-article",
                        stateUrl: window.location.hash
                    };
                    article.reject();
                });
                return article.promise;
            }
        }
    });
}]);

app.controller('editArticleController', function($scope, $stateParams, article,  articleService, helpFactory, eventHandlerFactory, objectUtils) {
    // get parent variables
    $scope.article = angular.copy(article);
    $scope.originalArticle = article;

    // initialize local variables
    $scope.imageSizes = [
        { label: 'big', size: 300 },
        { label: 'medium', size: 210 },
        { label: 'small', size: 100 }
    ];
    $scope.defaultSrc = $scope.article.images.big;
    $scope.image = {
        sizes: [
            { label: 'big', src: $scope.defaultSrc }
        ]
    };

    // set page title
    $scope.$emit('setPageTitle', 'Edit Article');

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope);

    // set help context
    helpFactory.setHelpContexts($scope, []);

    // returns true if the article is valid
    $scope.articleValid = function() {
        var article = $scope.article;
        return $scope.delete || (article.submitted_by && article.title && article.text_body);
    };

    // submits the updated article
    $scope.updateArticle = function() {
        // return if article is invalid
        if (!$scope.articleValid()) {
            return;
        }

        //delete the article if the box is checked
        if ($scope.delete) {
            $scope.deleteArticle();
            return;
        }

        // get changed article fields
        var articleId = $scope.article.id;
        var articleDiff = objectUtils.getDifferentObjectValues($scope.originalArticle, $scope.article);
        var articleLinks = [
            {
                link: "articles/" + articleId,
                linkLabel: "view the updated article."
            },
            {
                link: "articles",
                linkLabel: "return to the articles index."
            }
        ];
        articleDiff.id = articleId;

        // send the updated article fields to the backend
        $scope.startSubmission("Updating article...");
        articleService.updateArticle(articleDiff).then(function() {
            if (!$scope.image.changed) {
                $scope.submissionSuccess("Article updated successfully", articleLinks);
            }
        }, function(response) {
            $scope.submissionError("There were errors updating the article.", response);
        });

        // if we have a new article image, send it as well
        if ($scope.image.changed) {
            articleService.submitImage(articleId, $scope.image.sizes).then(function() {
                $scope.submissionSuccess("Article updated successfully", articleLinks);
            }, function(response) {
                $scope.submissionError("There were errors updating the article image.", response);
            });
        }
    };

    // deletes an article
    $scope.deleteArticle = function() {
        $scope.startSubmission("Deleting article...");
        articleService.deleteArticle($scope.article.id).then(function() {
            $scope.submissionSuccess("Article deleted successfully", [{ link: "articles", linkLabel: "return to the articles index."}]);
        }, function(response) {
            $scope.submissionError("There were errors deleting the article.", response);
        });
    };
});
