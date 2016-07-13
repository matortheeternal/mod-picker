app.service('contributionService', function (backend, $q, userTitleService, pageUtils, reviewSectionService, recordGroupService, pluginService, assetUtils) {
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
        var helpfulObj = helpful == undefined ? {} : {helpful: helpful};
        return backend.post('/' + route + '/' + id + '/helpful', helpfulObj);
    };

    this.agreementMark = function(route, id, agree) {
        var agreeObj = agree == undefined ? {} : {agree: agree};
        return backend.post('/' + route + '/' + id + '/agreement', agreeObj)
    };

    this.hide = function(route, id, hidden) {
        return backend.post('/' + route + '/' + id + '/hide', {hidden: hidden});
    };

    this.approve = function(route, id, approved) {
        return backend.post('/' + route + '/' + id + '/approve', {approved: approved});
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
            action.resolve(data.corrections);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveHistory = function(type, id) {
        var action = $q.defer();
        backend.retrieve('/' + type + '/' + id + '/history').then(function (data) {
            userTitleService.associateTitles(data);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };


    this.retrieveModContributions = function(modId, route, options, pageInformation) {
        var action = $q.defer();
        backend.post('/mods/' + modId + '/' + route, options).then(function (data) {
            var contributions = data[route];
            service.associateHelpfulMarks(contributions, data.helpful_marks);
            service.handleEditors(contributions);
            userTitleService.associateTitles(contributions);
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(contributions);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveModReviews = function(modId, options, pageInformation) {
        var action = $q.defer();
        backend.post('/mods/' + modId + '/reviews', options).then(function(data) {
            // prepare reviews
            var reviews = data.reviews;
            service.associateHelpfulMarks(reviews, data.helpful_marks);
            userTitleService.associateTitles(reviews);
            reviewSectionService.associateReviewSections(reviews);
            pageUtils.getPageInformation(data, pageInformation, options.page);
            // prepare user review if present
            if (data.user_review && data.user_review.id) {
                var user_review = [data.user_review];
                service.associateHelpfulMarks(user_review, data.helpful_marks);
                userTitleService.associateTitles(user_review);
                reviewSectionService.associateReviewSections(user_review);
            }
            // resolve data
            action.resolve({ reviews: data.reviews, user_review: data.user_review });
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveModAnalysis = function(modId) {
        var output = $q.defer();
        backend.retrieve('/mods/' + modId + '/' + 'analysis').then(function (analysis) {
            // turn assets into an array of string
            analysis.assets = analysis.assets.map(function(asset) {
                return asset.filepath;
            });
            // create nestedAssets tree
            analysis.nestedAssets = assetUtils.convertDataStringToNestedObject(analysis.assets);

            // prepare plugin data for display
            recordGroupService.associateGroups(analysis.plugins);
            pluginService.combineAndSortMasters(analysis.plugins);
            pluginService.associateOverrides(analysis.plugins);
            pluginService.sortErrors(analysis.plugins);

            output.resolve(analysis);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
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
});