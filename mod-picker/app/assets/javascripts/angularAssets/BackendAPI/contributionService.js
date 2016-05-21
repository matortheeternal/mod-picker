app.service('contributionService', function (backend, $q) {
    this.helpfulMark = function(type, id, helpful) {
        var mark = $q.defer();
        var helpfulObj = helpful == undefined ? {} : {helpful: helpful};
        backend.post('/' + type + '/' + id + '/helpful', helpfulObj).then(function (data) {
            mark.resolve(data);
        });
        return mark.promise;
    };

    this.hide = function(type, id, hidden) {
        var action = $q.defer();
        backend.post('/' + type + '/' + id + '/hide', {hidden: hidden}).then(function (data) {
            action.resolve(data);
        });
        return action.promise;
    };

    this.approve = function(type, id, approved) {
        var action = $q.defer();
        backend.post('/' + type + '/' + id + '/approve', {approved: approved}).then(function (data) {
            action.resolve(data);
        });
        return action.promise;
    };

    this.submitContribution = function(type, contribution) {
        var action = $q.defer();
        backend.post('/' + type, contribution).then(function (data) {
            action.resolve(data);
        });
        return action.promise;
    };

    this.updateContribution = function(type, contribution) {
        var action = $q.defer();
        backend.update('/' + type + '/' + contribution.id, contribution).then(function (data) {
            action.resolve(data);
        });
        return action.promise;
    };
});