app.service('articleService', function($q, backend, userTitleService, pageUtils) {
    this.retrieveArticle = function(articleId) {
        var output = $q.defer();
        backend.retrieve('/articles/' + articleId).then(function(articleData) {
            output.resolve(articleData);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.retrieveComments = function(articleId, options, pageInformation) {
        var output = $q.defer();
        backend.post('/articles/' + articleId+ '/comments', options).then(function(response) {
            userTitleService.associateTitles(response.comments);
            pageUtils.getPageInformation(response, pageInformation, options.page);
            output.resolve(response.comments);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };
});
