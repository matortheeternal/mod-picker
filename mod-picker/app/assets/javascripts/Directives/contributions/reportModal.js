app.directive('reportModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/reportModal.html',
        controller: 'reportModalController',
        scope: false
    };
});

app.controller('reportModalController', function($scope, reportService, eventHandlerFactory, formUtils) {
    $scope.unfocusReportModal = formUtils.unfocusModal($scope.toggleReportModal);

    // selectedTag's value is set to an object property because the select/option elements are within a child scope if ng-if
    // so updating just `selectedTag` within that child scope will NOT update its parent scope(this controller).
    $scope.selectedTag = { id: null };
    $scope.tagOptions = {};
    $scope.showTags = false;

    // modal message event handling
    eventHandlerFactory.buildModalMessageHandlers($scope);

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

    // show section for reporting tags, if tags are available.
    if($scope.target.tags && $scope.target.tags.length > 0) {
        $scope.showTags = true;
        var tags = $scope.target.tags;

        $scope.tagOptions = tags;
        $scope.selectedTag.id = tags[0].id;
    }
    

    $scope.submitReport = function() {
        if($scope.report.reason === '7') {
            // set reason to "Other" for Tag
            $scope.report.reason = '6';
            $scope.report.reportable_id = $scope.selectedTag.id;
            $scope.report.reportable_type = 'Tag';
        }

        reportService.submitReport($scope.report).then(function(report) {
            $scope.$emit('modalSuccessMessage', 'Report submitted successfully.');
            $scope.toggleReportModal(false);
        }, function(response) {
            var params = {label: 'Error submitting Report', response: response};
            $scope.$emit('modalErrorMessage', params);
        });
    };
});