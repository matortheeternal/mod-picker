app.service('contributionService', function (backend, $q) {
    this.helpfulMark = function(type, id, helpful) {
        var mark = $q.defer();
        var helpfulObj = helpful == undefined ? {} : {helpful: helpful};
        backend.post('/' + type + '/' + id + '/helpful', helpfulObj).then(function (data) {
            mark.resolve(data);
        });
        return mark.promise;
    };

    this.agreementMark = function(type, id, agree) {
        var mark = $q.defer();
        var agreeObj = agree == undefined ? {} : {agree: agree};
        backend.post('/' + type + '/' + id + '/agreement', agreeObj).then(function (data) {
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

    this.updateContribution = function(type, id, contribution) {
        var action = $q.defer();
        backend.update('/' + type + '/' + id, contribution).then(function (data) {
            action.resolve(data);
        });
        return action.promise;
    };

    this.retrieveCorrections = function(type, id) {
        var action = $q.defer();
        backend.retrieve('/' + type + '/' + id + '/corrections').then(function (data) {
            action.resolve(data);
        });
        return action.promise;
    };

    this.retrieveHistory = function(type, id) {
        var action = $q.defer();
        backend.retrieve('/' + type + '/' + id + '/history').then(function (data) {
            action.resolve(data);
        });
        return action.promise;
    };

    this.associateAgreementMarks = function(corrections, agreementMarks) {
        // loop through corrections
        corrections.forEach(function(correction) {
            // see if we have a matching agreement mark
            var agreementMark = agreementMarks.find(function(mark) {
                return mark.correction_id == correction.id;
            });
            // if we have a matching agreement mark, assign it to the correction
            if (agreementMark) {
                correction.agree = agreementMark.agree;
            }
        });
    };

    this.associateHelpfulMarks = function(contributions, helpfulMarks) {
        // loop through contributions
        contributions.forEach(function(contribution) {
            // see if we have a matching helpful mark
            var helpfulMark = helpfulMarks.find(function(mark) {
                return mark.helpfulable_id == contribution.id;
            });
            // if we have a matching helpful mark, assign it to the contribution
            if (helpfulMark) {
                contribution.helpful = helpfulMark.helpful;
            }
        });
    };
});