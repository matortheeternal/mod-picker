app.service('contributionService', function(backend, $q, userTitleService, pageUtils, reviewSectionService) {
    var service = this;

    this.retrieveContributions = function(route, options, pageInformation) {
        var action = $q.defer();
        backend.post('/' + route + '/index', options).then(function(data) {
            // associate other data
            var contributions = data[route];
            reviewSectionService.associateReviewSections(contributions);
            userTitleService.associateTitles(contributions);
            service.associateAgreementMarks(contributions, data.agreement_marks);
            service.associateHelpfulMarks(contributions, data.helpful_marks);

            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.helpfulMark = function(route, id, helpful) {
        var helpfulObj = helpful == undefined ? {} : { helpful: helpful };
        return backend.post('/' + route + '/' + id + '/helpful', helpfulObj);
    };

    this.agreementMark = function(route, id, agree) {
        var agreeObj = agree == undefined ? {} : { agree: agree };
        return backend.post('/' + route + '/' + id + '/agreement', agreeObj)
    };

    this.hide = function(route, id, hidden) {
        return backend.post('/' + route + '/' + id + '/hide', { hidden: hidden });
    };

    this.approve = function(route, id, approved) {
        return backend.post('/' + route + '/' + id + '/approve', { approved: approved });
    };

    this.submitContribution = function(route, contribution) {
        var action = $q.defer();
        backend.post('/' + route, contribution).then(function(data) {
            var contributions = [data];
            reviewSectionService.associateReviewSections(contributions);
            userTitleService.associateTitles(contributions);
            action.resolve(contributions[0]);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.updateContribution = function(route, id, contribution) {
        return backend.update('/' + route + '/' + id, contribution);
    };

    this.removeModeratorNote = function(route, id) {
        return backend.update('/' + route + '/' + id, { moderator_message: null });
    };

    this.retrieveComments = function(route, id, options, pageInformation) {
        var action = $q.defer();
        backend.post('/' + route + '/' + id + '/comments', options).then(function(data) {
            userTitleService.associateCommentTitles(data.comments);
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data.comments);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveCorrections = function(type, id) {
        var action = $q.defer();
        backend.retrieve('/' + type + '/' + id + '/corrections').then(function(data) {
            userTitleService.associateTitles(data.corrections);
            service.associateAgreementMarks(data.corrections, data.agreement_marks);
            action.resolve(data.corrections);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveHistory = function(type, id) {
        var action = $q.defer();
        backend.retrieve('/' + type + '/' + id + '/history').then(function(data) {
            userTitleService.associateTitles(data);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.handleEditors = function(contributions) {
        contributions.forEach(function(contribution) {
            if (contribution.editor && contribution.editors) {
                var editor = contribution.editors.find(function(editor) {
                    return editor.id == contribution.editor.id;
                });
                if (!editor) {
                    contribution.editors.unshift(contribution.editor);
                }
            }
            if (contribution.editors) {
                var index = contribution.editors.findIndex(function(editor) {
                    return editor.id == contribution.submitter.id;
                });
                if (index > -1) {
                    contribution.editors.splice(index, 1);
                }
            }
        });
    };

    this.associateAgreementMarks = function(corrections, agreementMarks) {
        // return if agreementMarks is undefined
        if (!agreementMarks) {
            return;
        }

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
        // return if helpfulMarks is undefined
        if (!helpfulMarks) {
            return;
        }

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

    this.removePrompts = function(text_body) {
        return text_body.replace(/([^\n]+)\uFEFF([^\n]+)([\n]+)/g, '');
    };
});
