app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.edit-article', {
        templateUrl: '/resources/partials/articles/editArticle.html',
        controller: 'editArticleController',
        url: '/article/:articleId/edit',
        resolve: {
            article: function(articleService, $stateParams, $q) {
                var article = $q.defer();
                articleService.retrieveArticle($stateParams.articleId).then(function(articleData) {
                    article.resolve(articleData);
                }, function(response) {
                    this.self.errorObj = {
                        text: 'Error retrieving article.',
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
        var articleDiff = objectUtils.getDifferentObjectValues($scope.originalArticle, $scope.article);
        articleDiff.id = $scope.article.id;

        // send the updated article fields to the backend
        articleService.updateArticle(articleDiff).then(function() {
            if (!$scope.image.file) {
                $scope.$emit('successMessage', 'Article updated successfully.');
            }
        }, function(response) {
            var params = { label: 'Error updating article', response: response };
            $scope.$emit('errorMessage', params);
        });

        // if we have a new article image, send it as well
        if ($scope.image.file) {
            articleService.submitImage($scope.article.id, $scope.image.file).then(function() {
                $scope.$emit('successMessage', 'Article updated successfully.');
            }, function(response) {
                var params = { label: 'Error updating article image', response: response };
                $scope.$emit('errorMessage', params);
            });
        }
    };

    // deletes an article
    $scope.deleteArticle = function() {
        articleService.deleteArticle($scope.article.id).then(function() {
            $scope.$emit('successMessage', 'Article deleted successfully.');
        }, function(response) {
            var params = { label: 'Error deleting article', response: response };
            $scope.$emit('errorMessage', params);
        });
    };
});
