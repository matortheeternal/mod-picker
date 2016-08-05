app.directive('displayReportsModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/displayReportsModal.html',
        controller: 'displayReportsController'
    };
});

app.controller('displayReportsController', function($scope, reportService) {
    reportService.retrieveContributionReports($scope.modelName, $scope.target.id, $scope.pages.reports).then(function(reportObject) {
        $scope.reports = reportObject.reports;
        $scope.baseReportId = reportObject.id;
    });

    $scope.removeReports = function(report) {
      reportService.removeBaseReport($scope.baseReportId);
    };
});
