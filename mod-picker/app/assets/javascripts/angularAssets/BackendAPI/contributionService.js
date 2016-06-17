app.service('contributionService', function (backend, $q, userTitleService, pageUtils) {
    var service = this;

    this.helpfulMark = function(type, id, helpful) {
        var helpfulObj = helpful == undefined ? {} : {helpful: helpful};
        return backend.post('/' + type + '/' + id + '/helpful', helpfulObj);
    };

    this.agreementMark = function(type, id, agree) {
        var agreeObj = agree == undefined ? {} : {agree: agree};
        return backend.post('/' + type + '/' + id + '/agreement', agreeObj)
    };

    this.hide = function(type, id, hidden) {
        return backend.post('/' + type + '/' + id + '/hide', {hidden: hidden});
    };

    this.approve = function(type, id, approved) {
        return backend.post('/' + type + '/' + id + '/approve', {approved: approved});
    };

    this.submitContribution = function(type, contribution) {
        return backend.post('/' + type, contribution);
    };

    this.updateContribution = function(type, id, contribution) {
        return backend.update('/' + type + '/' + id, contribution);
    };

    this.retrieveComments = function(route, id, options, pageInformation) {
        var action = $q.defer();
        backend.post('/' + route + '/' + id + '/comments', options).then(function(data) {
            userTitleService.associateTitles(data.comments);
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data.comments);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveCorrections = function(type, id) {
        var action = $q.defer();
        backend.retrieve('/' + type + '/' + id + '/corrections').then(function (data) {
            userTitleService.associateTitles(data.corrections);
            service.associateAgreementMarks(data.corrections, data.agreement_marks);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveHistory = function(type, id) {
        var action = $q.defer();
        backend.retrieve('/' + type + '/' + id + '/history').then(function (data) {
            userTitleService.associateTitles(data.history);
            action.resolve(data.history);
        }, function(response) {
            action.reject(response);
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