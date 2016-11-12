app.service('curatorRequestService', function($q, backend, userTitleService, pageUtils) {
    this.retrieveCuratorRequests = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/curator_requests/index', options).then(function(data) {
            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);
            userTitleService.associateTitles(data.curator_requests);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.changeState = function(curatorRequestId, newState) {
        return backend.update('/curator_requests/ '+ curatorRequestId, { state: newState });
    };

    this.submitCuratorRequest = function(curatorRequest) {
        return backend.post('/curator_requests', curatorRequest);
    };
});
