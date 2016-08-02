app.directive('reportModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/reportModal.html',
        controller: 'reportController',
        scope: false
    };
});

app.controller('reportController', function($scope, reportService) {
    $scope.submitReport = function() {
        reportService.submitReport($scope.report);
        $scope.toggleReportModal(false);
    };
});
