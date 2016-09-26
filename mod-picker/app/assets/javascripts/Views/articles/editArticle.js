app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.edit-article', {
        templateUrl: '/resources/partials/articles/editArticle.html',
        controller: 'editArticleController',
        url: '/article/:articleId/edit',
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

app.controller('editArticleController', function($scope, $stateParams, article,  articleService, eventHandlerFactory, objectUtils) {
    // get parent variables
    $scope.article = angular.copy(article);
    $scope.originalArticle = article;

    // initialize local variables
    $scope.image = {
        src: $scope.article.image
    };

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope);

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
        articleDiff.id = articleId;

        // send the updated article fields to the backend
        $scope.startSubmission("Updating article...");
        articleService.updateArticle(articleDiff).then(function() {
            if (!$scope.image.file) {
                $scope.submissionSuccess("Article updated successfully", "#/article/" + articleId, "view the updated article.");
            }
        }, function(response) {
            $scope.submissionError("There were errors updating the article.", response);
        });

        // if we have a new article image, send it as well
        if ($scope.image.file) {
            articleService.submitImage(articleId, $scope.image.file).then(function() {
                $scope.submissionSuccess("Article updated successfully", "#/article/" + articleId, "view the updated article.");
            }, function(response) {
                $scope.submissionError("There were errors updating the article image.", response);
            });
        }
    };

    // deletes an article
    $scope.deleteArticle = function() {
        $scope.startSubmission("Deleting article...");
        articleService.deleteArticle($scope.article.id).then(function() {
            $scope.submissionSuccess("Article deleted successfully", "#/articles", "return to the articles index.");
        }, function(response) {
            $scope.submissionError("There were errors deleting the article.", response);
        });
    };
});
