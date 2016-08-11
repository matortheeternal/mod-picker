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

app.controller('editArticleController', function($scope, $stateParams, article, objectUtils, articleService) {
    $scope.article = angular.copy(article);
    $scope.originalArticle = article;

    $scope.image = {
        src: $scope.article.image
    };

    $scope.articleValid = function() {
        var article = $scope.article;

        return article.submitted_by && article.title && article.text_body || $scope.delete;
    };

    $scope.updateArticle = function() {
        //delete the article if the box is checked
        if ($scope.delete) {
            $scope.deleteArticle();
            return;
        }

        // get changed article fields
        var articleDiff = objectUtils.getDifferentObjectValues($scope.originalArticle, $scope.article);

        // return if article is invalid
        if (!$scope.articleValid()) {
            return;
        }

        $scope.submitting = true;
        $scope.submittingStatus = "Updating Article...";
        articleDiff.id = $scope.article.id;
        articleService.updateArticle(articleDiff).then(function() {
            if (!angular.isDefined($scope.success)) {
                $scope.success = true;
                if (!$scope.image.file) {
                    $scope.submittingStatus = "Article Updated Successfully!";
                }
            } else if ($scope.success) {
                $scope.submittingStatus = "Article Updated Successfully!";
            }
        }, function(response) {
            $scope.success = false;
            $scope.submittingStatus = "There were errors updating the article.";
            // TODO: Emit errors properly
            $scope.errors = response.data;
        });
        if ($scope.image.file) {
            articleService.submitImage($scope.article.id, $scope.image.file).then(function () {
                if (!angular.isDefined($scope.success)) {
                    $scope.success = true;
                } else if ($scope.success) {
                    $scope.submittingStatus = "Article Updated Successfully!";
                }
            }, function(response) {
                $scope.success = false;
                $scope.submittingStatus = "There were errors updating the article.";
                // TODO: Emit errors properly
                $scope.errors = response.data;
            });
        }
    };

    $scope.deleteArticle = function() {
        $scope.submitting = true;
        $scope.submittingStatus = "Deleting Article...";
        articleService.deleteArticle($scope.article.id).then(function() {
            $scope.success = true;
            $scope.submittingStatus = "Article Deleted Successfully!";
        }, function(response) {
            $scope.success = false;
            $scope.submittingStatus = "There were errors deleting the article.";
            // TODO: Emit errors properly
            $scope.errors = response.data;
        });
    };

    $scope.closeModal = function() {
        delete $scope.success;
        delete $scope.submitting;
        delete $scope.errors;
    };

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        if (params.label && params.response) {
            var errors = errorService.errorMessages(params.label, params.response);
            errors.forEach(function(error) {
                $scope.$broadcast('message', error);
            });
        } else {
            $scope.$broadcast('message', params);
        }
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display success message
    $scope.$on('successMessage', function(event, text) {
        var successMessage = {type: "success", text: text};
        $scope.$broadcast('message', successMessage);
        // stop event propagation - we handled it
        event.stopPropagation();
    });
});
