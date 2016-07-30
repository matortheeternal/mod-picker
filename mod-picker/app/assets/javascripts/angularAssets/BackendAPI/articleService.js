app.service('articleService', function(backend, $q, objectUtils) {
    this.retrieveArticle = function(articleId) {
        var output = $q.defer();
        backend.retrieve('/articles/' + articleId).then(function(articleData) {
            output.resolve(articleData);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.updateArticle = function(article) {
        // prepare mod record
        var articleData = {
            article: {
                id: article.id,
                title: article.title,
                submitted_by: article.submitted_by,
                text_body: article.text_body
            }
        };
        objectUtils.deleteEmptyProperties(articleData, 1);

        // submit mod
        return backend.update('/articles/' + article.id, articleData);
    };

    this.submitImage = function(articleId, image) {
        return backend.postFile('/articles/' + articleId + '/image', 'image', image);
    };
});
