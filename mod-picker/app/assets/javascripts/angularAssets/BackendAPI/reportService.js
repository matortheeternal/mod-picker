app.service('reportService', function($q, backend, pageUtils, userTitleService, reviewSectionService) {
    this.retrieveReport = function(reportId) {
        var output = $q.defer();
        backend.retrieve('/reports/' + reportId).then(function(reportData) {
            output.resolve(reportData);
        }, function(response) {
            output.reject(response);
        });
        return output.promise;
    };

    this.retrieveReports = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/reports/index', options).then(function(data) {
            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);
            // TODO: associate user titles, agreement marks, helpful marks

            // array of reportables
            var reportableArray = data.reports.map(function(obj) {
                return obj.reportable;
            });

            // associate titles to reportable submitter if relevant
            userTitleService.associateTitles(reportableArray);

            // associate reportable user titles and review section ratings
            data.reports.forEach(function(obj) {
                if(obj.reportable_type === 'User' && !obj.reportable.title) {
                    userTitleService.getUserTitle(obj.reportable.reputation.overall).then(function(title) {
                        obj.reportable.title = title;
                    });
                }

                if(obj.reportable_type === 'Review') {
                    reviewSectionService.associateReviewSections([obj.reportable]);
                }
            });

            

            action.resolve(data);

        }, function(response) {
            action.reject(response);
        });

        return action.promise;
    };

    this.submitReport = function(report) {
        // prepare report record
        var reportData = {
            report: {
                report_type: report.report_type,
                note: report.note
            },
            base_report: {
                reportable_id: report.reportable_id,
                reportable_type: report.reportable_type
            }
        };

        // submit report
        return backend.post('/reports', reportData);
    };
});