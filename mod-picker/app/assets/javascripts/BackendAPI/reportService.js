app.service('reportService', function($q, backend, pageUtils, userTitleService, reviewSectionService) {
    this.retrieveReports = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/reports/index', options).then(function(data) {
            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);

            // associate titles to reportable submitter or User
            userTitleService.associateReportableTitles(data.reports);
            var reportableArray = data.reports.map(function(obj) {
                return obj.reportable;
            });
            reviewSectionService.associateReviewSections(reportableArray);

            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });

        return action.promise;
    };

    this.resolveReport = function(reportId, resolved) {
        return backend.post('/reports/' + reportId + '/resolve', {resolved: resolved});
    };

    this.submitReport = function(report) {
        var action = $q.defer();
        
        // prepare report record
        var reportData = {
            report: {
                reason: report.reason,
                note: report.note
            },
            base_report: {
                reportable_id: report.reportable_id,
                reportable_type: report.reportable_type
            }
        };

        // submit report
        backend.post('/reports', reportData).then(function(data) {
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });

        return action.promise;
    };
});