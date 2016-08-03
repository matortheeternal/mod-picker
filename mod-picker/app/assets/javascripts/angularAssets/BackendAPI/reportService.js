app.service('reportService', function($q, backend) {

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
    }
});
