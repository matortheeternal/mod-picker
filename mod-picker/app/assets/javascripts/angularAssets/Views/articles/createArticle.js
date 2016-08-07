app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.create-article', {
        templateUrl: '/resources/partials/articles/createArticle.html',
        controller: 'createArticleController',
        url: '/articles/submit'
    });
}]);

app.controller('createArticleController', function($scope, $stateParams, objectUtils, articleService) {
    $scope.article = {};

    $scope.image = {
        src: $scope.article.image
    };

    $scope.articleValid = function() {
        var article = $scope.article;

        return article.title && article.text_body;
    };

    $scope.submit = function () {
        // return if mod is invalid
        if (!$scope.articleValid()) {
            return;
        }
        $scope.submitting = true;

        $scope.submittingStatus = "Submitting article..";
        articleService.submitArticle($scope.article).then(function(response) {
            var articleId = response.id;
            if ($scope.image.file) {
                articleService.submitImage(articleId, $scope.image.file).then(function () {
                    $scope.success = true;
                    $scope.submittingStatus = "Article submitted Successfully!";
                }, function(response) {
                    $scope.success = false;
                    $scope.submittingStatus = "There were errors submitting the article.";
                    // TODO: Emit errors properly
                    $scope.errors = response.data;
                });
            } else {
                $scope.submittingStatus = "Article submitted Successfully!";
                $scope.success = true;
            }
        }, function(response) {
            $scope.success = false;
            $scope.submittingStatus = "There were errors submitting the article.";
            // TODO: Emit errors properly
            $scope.errors = response.data;
        });
    };

    $scope.closeModal = function() {
        delete $scope.success;
        delete $scope.submitting;
        delete $scope.errors;
    };
});
