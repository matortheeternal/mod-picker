app.service('reportService', function($q, backend, pageUtils) {
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
        backend.post('/reports/index', options).then(function (data) {
            // resolve page information and data
            pageUtils.getPageInformation(data, pageInformation, options.page);
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
