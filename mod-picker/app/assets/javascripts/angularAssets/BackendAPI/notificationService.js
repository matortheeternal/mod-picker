app.service('notificationService', function($q, backend) {
    this.retrieveNotifications = function() {
        return backend.retrieve('/notifications');
    };

    this.retrieveRecent = function() {
        return backend.retrieve('/notifications/recent');
    };

    this.markRead = function(ids) {
        return backend.post('/notifications/read', { ids: ids });
    };
});
