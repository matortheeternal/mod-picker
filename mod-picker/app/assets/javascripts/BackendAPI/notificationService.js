app.service('notificationService', function($q, backend, pageUtils) {
    this.retrieveNotifications = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/notifications', options).then(function(data) {
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveRecent = function() {
        return backend.retrieve('/notifications/recent');
    };

    this.markRead = function(ids) {
        return backend.post('/notifications/read', { ids: ids });
    };
});
