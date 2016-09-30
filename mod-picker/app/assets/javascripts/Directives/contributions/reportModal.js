app.directive('reportModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/reportModal.html',
        controller: 'reportModalController',
        scope: false
    };
});

app.controller('reportModalController', function($scope, reportService) {
    $scope.tagOptions = {};
    $scope.selectedTag = {};
    $scope.showTags = false;

    // helper function to convert id of tags(which by default is stored as a string) to int
    $scope.convertToInt = function(id) {
        return parseInt(id, 10);
    };

    $scope.getModalTitle = function() {
        var submitter = $scope.target.submitter ? $scope.target.submitter.username + '\'s ' : '';

        var modelName = '';

        switch ($scope.modelObj.name) {
            case 'User':
                modelName = $scope.target.username;
                break;
            case 'ModList':
                modelName = $scope.target.name;

                // manually disabling the display of modlist submitter
                submitter = '';
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

    // section for reporting tags, if tags are available.
    if($scope.target.tags && $scope.target.tags.length > 0) {
        $scope.showTags = true;
        var tags = $scope.target.tags;

        $scope.tagOptions = tags;
        $scope.selectedTag = $scope.convertToInt(tags[0].id);
        console.log($scope.target.tags);

    }
    

    $scope.submitReport = function() {
        if($scope.report.reason === '7') {
            // set reason to "Other" for Tag
            $scope.report.reason = '6';
            $scope.report.reportable_id = $scope.selectedTag;
            $scope.report.reportable_type = 'Tag';

            console.log($scope.report);
        }

        reportService.submitReport($scope.report);
        $scope.toggleReportModal(false);
    };
});