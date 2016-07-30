app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.create-article', {
        templateUrl: '/resources/partials/articles/createArticle.html',
        controller: 'createArticleController',
        url: '/create-article'
    });
}]);

app.controller('createArticleController', function($scope, $stateParams, objectUtils, articleService) {
    $scope.article = {};

    $scope.image = {
        src: $scope.article.image
    };

    $scope.articleValid = function() {
        var article = $scope.article;

        return article.submitted_by && article.title && article.text_body;
    };

    $scope.submit = function () {
        // return if mod is invalid
        if (!$scope.articleValid()) {
            return;
        }

        $scope.submittingStatus = "Submitting article..";
        articleService.submitArticle($scope.articles).then(function() {
            $scope.submittingStatus = "Article Submitted Successfully!";
            $scope.success = true;
        }, function(response) {
            $scope.submittingStatus = "There were errors submitting your article.";
            $scope.errors = response.data;
        });
    };

    $scope.closeModal = function() {
        delete $scope.success;
        delete $scope.submitting;
        delete $scope.errors;
    };
});
