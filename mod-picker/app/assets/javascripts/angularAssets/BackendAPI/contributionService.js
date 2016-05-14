app.service('contributionService', function (backend, $q) {
    this.helpfulMark = function(type, id, helpful) {
        var mark = $q.defer();
        var helpfulObj = helpful == undefined ? {} : {helpful: helpful};
        backend.post('/' + type + '/' + id + '/helpful', helpfulObj).then(function (data) {
            mark.resolve(data);
        });
        return mark.promise;
    };
});