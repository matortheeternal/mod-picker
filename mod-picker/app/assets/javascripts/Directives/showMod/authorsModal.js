app.directive('authorsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/authorsModal.html',
        scope: false,
        controller: 'authorsModalController'
    };
});

app.controller('authorsModalController', function($scope, curatorRequestService, contributionService, eventHandlerFactory, contributionFactory, formUtils) {
    // inherited functions
    $scope.unfocusAuthorsModal = formUtils.unfocusModal($scope.toggleAuthorsModal);

    // initialize variables
    $scope.canCreateCuratorRequest = $scope.currentUser.reputation.overall > 20;
    if ($scope.canCreateCuratorRequest) {
        $scope.curatorRequestTitle = 'Click here if you would like to curate this mod.';
    } else {
        $scope.curatorRequestTitle = 'You do not have enough reputation to submit a curator request for \nthis mod.';
    }

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    // update the markdown editor
    $scope.updateEditor = function() {
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    // start a new curator request
    $scope.startNewCuratorRequest = function() {
        $scope.activeRequest = {
            text_body: contributionFactory.getDefaultTextBody("CuratorRequest")
        };

        // update editor
        $scope.updateEditor(true);
    };

    $scope.validateCuratorRequest = function() {
        var sanitized_text = contributionService.removePrompts($scope.activeRequest.text_body);
        $scope.activeRequest.valid = sanitized_text.length > 32;
    };

    // discard a new curator request object
    $scope.discardCuratorRequest = function() {
        delete $scope.activeRequest;
    };

    // save a curator request
    $scope.saveCuratorRequest = function() {
        // return if the appeal is invalid
        if (!$scope.activeRequest.valid) {
            return;
        }

        // submit the appeal
        var sanitized_text = contributionService.removePrompts($scope.activeRequest.text_body);
        var curatorRequestObj = {
            curator_request: {
                mod_id: $scope.mod.id,
                text_body: sanitized_text
            }
        };
        $scope.activeRequest.submitting = true;

        // use update or submit contribution
        curatorRequestService.submitCuratorRequest(curatorRequestObj).then(function() {
            $scope.$emit("modalSuccessMessage", "Curator request submitted successfully.");
            $scope.discardCuratorRequest();
        }, function(response) {
            var params = {label: 'Error submitting curator request', response: response};
            $scope.$emit('modalErrorMessage', params);
        });
    };
});
