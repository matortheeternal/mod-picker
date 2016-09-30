app.directive('reportModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/reportModal.html',
        controller: 'reportModalController',
        scope: false
    };
});

app.controller('reportModalController', function($scope, reportService) {
    $scope.getModalTitle = function() {
        var submitter = $scope.target ? $scope.target.submitter.username + '\'s ' : '';

        var modelName = '';

        switch ($scope.modelObj.name) {
            case 'User':
                modelName = $scope.target.username;
                break;
            case 'ModList':
                modelName = $scope.target.name;
                break;
            case 'Mod':
                modelName = $scope.target.name;
                break;
            default:
                modelName = $scope.modelObj.name;
        }
        
        var title = 'Report ' + submitter + modelName;
        return title;
    };

    $scope.submitReport = function() {
        reportService.submitReport($scope.report);
        $scope.toggleReportModal(false);
    };
});