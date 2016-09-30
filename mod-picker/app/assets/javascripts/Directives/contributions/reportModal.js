app.directive('reportModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/reportModal.html',
        controller: 'reportModalController',
        scope: false
    };
});

app.controller('reportModalController', function($scope, reportService) {
    // setup model name and submitter(if content has submitter) for reportable
    var submitter = $scope.target ? $scope.target.submitter.username + '\'s ' : '';

    // // each reportable content must include modelObj in its scope which is inherited by the reportModal
    var modelName = $scope.modelObj ? $scope.modelObj.name : '';

    $scope.reportTitle = 'Report ' + submitter + modelName;

    $scope.submitReport = function() {
        reportService.submitReport($scope.report);
        $scope.toggleReportModal(false);
    };
});
