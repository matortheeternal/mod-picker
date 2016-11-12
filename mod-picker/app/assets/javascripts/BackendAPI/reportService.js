app.service('reportService', function($q, backend, pageUtils, userTitleService, reviewSectionService, modService) {
    var service = this;

    this.retrieveReports = function(options, pageInformation) {
        var action = $q.defer();
        backend.post('/reports/index', options).then(function(data) {
            pageUtils.getPageInformation(data, pageInformation, options.page);
            userTitleService.associateReportableTitles(data.reports);
            service.associateModImages(data.reports);
            var reportables = service.getReportables(data.reports);
            reviewSectionService.associateReviewSections(reportables);
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

    this.getReportables = function(reports) {
        return reports.map(function(obj) {
            return obj.reportable;
        });
    };

    this.associateModImages = function(reports) {
        reports.forEach(function(report) {
            if (report.reportable_type !== 'Mod') return;
            modService.associateModImage(report.reportable);
        });
    };
});