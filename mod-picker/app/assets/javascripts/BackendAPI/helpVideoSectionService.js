app.service('helpVideoSectionService', function($q, backend) {
    var service = this;

    this.retrieveSections = function(helpVideoId) {
        return backend.retrieve("/videos/" + helpVideoId + "/sections")
    };
});
