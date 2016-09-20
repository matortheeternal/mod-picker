app.service('articleService', function($q, backend, userTitleService, pageUtils, objectUtils) {
    this.retrieveArticle = function(articleId) {
        var output = $q.defer();
        backend.retrieve('/articles/' + articleId).then(function(articleData) {
            output.resolve(articleData);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.retrieveArticles = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/articles/index', options).then(function (data) {
            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.newArticle = function() {
        return backend.retrieve('/articles/new');
    };

    this.editArticle = function(articleId) {
        return backend.retrieve('/articles/' + articleId + '/edit');
    };

    this.updateArticle = function(article) {
        // prepare article record
        var articleData = {
            article: {
                id: article.id,
                title: article.title,
                submitted_by: article.submitted_by,
                text_body: article.text_body
            }
        };
        objectUtils.deleteEmptyProperties(articleData, 1);

        // submit article
        return backend.update('/articles/' + article.id, articleData);
    };

    this.submitArticle = function(article) {
        // prepare article record
        var articleData = {
            article: {
                title: article.title,
                text_body: article.text_body
            }
        };

        // submit article
        return backend.post('/articles', articleData);
    };

    this.deleteArticle = function(articleId) {
        return backend.delete('/articles/' + articleId);
    };

    this.submitImage = function(articleId, image) {
        return backend.postFile('/articles/' + articleId + '/image', 'image', image);
    };
});
