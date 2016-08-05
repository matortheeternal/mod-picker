app.directive('displayReportsModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/displayReportsModal.html',
        controller: 'displayReportsController'
    };
});

app.controller('displayReportsController', function($scope, $filter, reportService) {
    reportService.retrieveContributionReports($scope.modelName, $scope.target.id, $scope.pages.reports).then(function(reportObject) {
        $scope.reports = reportObject.reports;
        $scope.baseReportId = reportObject.id;
    });

    $scope.removeReports = function() {
      reportService.removeBaseReport($scope.baseReportId);
    };

    $scope.getDateString = function(report) {
        var str = "submitted " + $filter('date')(report.submitted, 'medium');
        if (report.edited) {
            str += ", edited " + $filter('date')(report.edited, 'medium');
        }
        return str;
    };
});
