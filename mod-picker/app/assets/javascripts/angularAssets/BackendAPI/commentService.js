app.service('commentService', function($q, backend, pageUtils, userTitleService) {
    this.retrieveComments = function(objectId, objectType, options, pageInformation) {
        var output = $q.defer();
        backend.post('/' + objectType + 's/' + objectId + '/comments', options).then(function(response) {
            userTitleService.associateTitles(response.comments);
            pageUtils.getPageInformation(response, pageInformation, options.page);
            output.resolve(response.comments);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };
});
