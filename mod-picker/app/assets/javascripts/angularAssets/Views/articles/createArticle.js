app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.create-article', {
        templateUrl: '/resources/partials/articles/createArticle.html',
        controller: 'createArticleController',
        url: '/articles/submit'
    });
}]);

app.controller('createArticleController', function($scope, $stateParams, articleService, eventHandlerFactory) {
    // set up local variables
    $scope.article = {};
    $scope.image = {
        src: $scope.article.image
    };

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope);

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
            if ($scope.image.file) {
                $scope.submitImage(data.id);
            } else {
                $scope.submissionSuccess("Article submitted successfully.", "#/article/"+articleId, "view the new article.");
            }
        }, function(response) {
            $scope.submissionError("There were errors submitting the article.", response);
        });
    };

    $scope.submitImage = function(articleId) {
        articleService.submitImage(articleId, $scope.image.file).then(function() {
            $scope.submissionSuccess("Article submitted successfully.", "#/article/"+articleId, "view the new article.");
        }, function() {
            $scope.submissionSuccess("Article submitted successfully, image submission failed.", "#/article/"+articleId, "view the new article.");
        });
    };
});
