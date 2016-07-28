app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.article', {
        templateUrl: '/resources/partials/articles/article.html',
        controller: 'articleController',
        url: '/article/:articleId'
    });
}]);

app.controller('articleController', function($scope) {
    
});
