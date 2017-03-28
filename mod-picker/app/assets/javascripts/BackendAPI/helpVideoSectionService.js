app.service('helpVideoSectionService', function($q, backend) {
    this.retrieveSections = function(helpPageId) {
        return backend.retrieve("/help/" + helpPageId + "/sections");
    };
});
