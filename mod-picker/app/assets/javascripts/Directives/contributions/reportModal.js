app.directive('reportModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/reportModal.html',
        controller: 'reportModalController',
        scope: false
    };
});

app.controller('reportModalController', function($scope, reportService) {
    $scope.submitReport = function() {
        reportService.submitReport($scope.report);
        $scope.toggleReportModal(false);
    };
});
