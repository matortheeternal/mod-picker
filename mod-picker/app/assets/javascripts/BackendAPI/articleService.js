app.service('articleService', function($q, backend, userTitleService, pageUtils, objectUtils) {
    var service = this;

    this.retrieveArticles = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/articles/index', options).then(function(data) {
            service.associateArticleImages(data.articles);
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveArticle = function(articleId) {
        var output = $q.defer();
        backend.retrieve('/articles/' + articleId).then(function(articleData) {
            service.associateArticleImage(articleData);
            output.resolve(articleData);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.newArticle = function() {
        return backend.retrieve('/articles/new');
    };

    this.editArticle = function(articleId) {
        var output = $q.defer();
        backend.retrieve('/articles/' + articleId + '/edit').then(function(articleData) {
            service.associateArticleImage(articleData);
            output.resolve(articleData);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
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

    this.submitImage = function(articleId, images) {
        return backend.postImages('/articles/' + articleId + '/image', images);
    };

    this.associateArticleImage = function(article) {
        var imageBase = article.image_type ? article.id : 'Default';
        var imageExt = article.image_type || 'png';
        article.images = {
            big: '/articles/' + imageBase + '-big.' + imageExt,
            medium: '/articles/' + imageBase + '-medium.' + imageExt,
            small: '/articles/' + imageBase + '-small.' + imageExt
        };
    };

    this.associateArticleImages = function(articles) {
        if (!articles) return;
        articles.forEach(service.associateArticleImage);
    };
});
