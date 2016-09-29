app.directive('submissionModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/submissionModal.html',
        scope: false,
        controller: 'submissionModalController'
    }
});

app.controller('submissionModalController', function($scope) {
    $scope.startSubmission = function(label) {
        $scope.submitting = true;
        $scope.submittingStatus = label;
    };

    $scope.submissionSuccess = function(label, link, linkLabel) {
        $scope.submittingStatus = label;
        $scope.successLink = link;
        $scope.successLabel = linkLabel;
        $scope.success = true;
    };

    $scope.submissionError = function(label, response) {
        $scope.submittingStatus = label;
        $scope.errors = response.data;
        $scope.success = false;
    };

    $scope.closeModal = function() {
        delete $scope.success;
        delete $scope.submitting;
        delete $scope.errors;
    };
});