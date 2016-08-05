app.service('reportService', function($q, backend, pageUtils) {
    var service = this;
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

    this.retrieveReports = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/reports/index', options).then(function (data) {
            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);
            action.resolve(data);
        }, function(response) {
            action.reject(response);
        });
        return action.promise;
    };

    this.retrieveContributionReports = function(contributionType, contributionId) {
        var base_report = $q.defer();
        var params = {
            reportable_type: contributionType,
            reportable_id: contributionId
        };
        backend.post('/reports/contribution', params).then(function(data) {
            base_report.resolve(data);
        });
        return base_report.promise;
    };
});
