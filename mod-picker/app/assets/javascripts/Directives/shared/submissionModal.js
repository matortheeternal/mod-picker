app.directive('submissionModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/submissionModal.html',
        scope: false,
        controller: 'submissionModalController'
    }
});

app.controller('submissionModalController', function($scope, errorService) {
    $scope.startSubmission = function(label) {
        $scope.submitting = true;
        $scope.submittingStatus = label;
        $scope.$emit('toggleModal', true);
    };

    $scope.submissionSuccess = function(label, linksList) {
        // array of objects containing linkLabel and link in case success message
        // needs multiple links
        $scope.linksList = linksList;
        $scope.submittingStatus = label;
        $scope.success = true;
    };

    $scope.submissionError = function(label, response) {
        $scope.submittingStatus = label;
        $scope.errors = errorService.flattenErrors(response);
        $scope.success = false;
    };

    $scope.closeModal = function() {
        delete $scope.success;
        delete $scope.submitting;
        delete $scope.errors;
        $scope.$emit('toggleModal', false);
    };
});