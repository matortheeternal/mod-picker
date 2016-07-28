app.service('articleService', function(backend, $q) {
    this.retrieveArticle = function(articleId) {
        var output = $q.defer();
        backend.retrieve('/articles/' + articleId).then(function(articleData) {
            output.resolve(articleData);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };
});
