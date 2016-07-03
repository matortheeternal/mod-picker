app.directive('correctionsModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/correctionsModal.html',
        controller: 'correctionsModalController',
        scope: false
    };
});

app.controller('correctionsModalController', function ($scope, contributionService, errorService) {
    // compute agree percentage helper
    $scope.computeAgreePercentage = function(correction) {
        return (correction.agree_count / ((correction.agree_count + correction.disagree_count) || 1)) * 100;
    };

    // display error messages
    $scope.$on('modalErrorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response);
        errors.forEach(function(error) {
            $scope.$broadcast('modalMessage', error);
        });
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display success message
    $scope.$on('modalSuccessMessage', function(event, text) {
        var successMessage = {type: "success", text: text};
        $scope.$broadcast('modalMessage', successMessage);
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // start a new correction
    $scope.startNewCorrection = function() {
        $scope.activeCorrection = {
            title: "",
            text_body: "" // TODO: Get template from the contributionFactory
        };

        // update editor
        $scope.updateEditor(true);
    };

    // edit an existing correction
    $scope.editCorrection = function(correction) {
        correction.editing = true;
        $scope.activeCorrection = {
            title: correction.title.slice(0),
            text_body: correction.text_body.slice(0),
            original: correction,
            editing: true
        };

        // update validation, update the markdown editor
        $scope.validateCorrection();
        $scope.updateEditor(true);
    };

    $scope.retrieveCorrectionComments = function(page) {
        // TODO: Make options dynamic
        var options = {
            sort: {
                column: 'submitted',
                direction: 'desc'
            },
            page: page || 1
        };
        contributionService.retrieveComments('corrections', $scope.correction.id, options, $scope.pages.correction_comments).then(function(data) {
            $scope.correction.comments = data;
            delete $scope.correction.retrieving_comments;
        }, function(response) {
            $scope.errors.correction_comments = response;
        });
    };

    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    $scope.showCorrection = function(correction) {
        $scope.correction = correction;
        if (!correction.comments && !correction.retrieving_comments) {
            correction.retrieving_comments = true;
            $scope.retrieveCorrectionComments();
        }
    };

    $scope.showIndex = function() {
        // NOTE: It's important that we're not deleting this, as that would remove
        // the correction from the index view as well, which is not desireable
        $scope.correction = null;
    };

    $scope.validateCorrection = function() {
        $scope.activeCorrection.valid = ($scope.activeCorrection.title.length > 4) &&
            ($scope.activeCorrection.text_body.length > 256);
    };

    // discard a new correction object or stop editing an existing one
    $scope.discardCorrection = function() {
        if ($scope.activeCorrection.editing) {
            $scope.activeCorrection.original.editing = false;
            $scope.activeCorrection = null;
        } else {
            delete $scope.activeCorrection;
        }
    };

    // update an correction locally
    $scope.updateCorrection = function () {
        var originalCorrection = $scope.activeCorrection.original;
        var updatedCorrection = $scope.activeCorrection;
        // update the values on the original correction
        originalCorrection.title = updatedCorrection.title.slice(0);
        originalCorrection.text_body = updatedCorrection.text_body.slice(0);
    };

    // save an correction
    $scope.saveCorrection = function() {
        // return if the correction is invalid
        if (!$scope.activeCorrection.valid) {
            return;
        }

        // submit the correction
        var correctionObj = {
            correction: {
                game_id: $scope.target.game_id,
                correctable_id: $scope.target.id,
                correctable_type: $scope.model.name,
                title: $scope.activeCorrection.title,
                text_body: $scope.activeCorrection.text_body
            }
        };
        $scope.activeCorrection.submitting = true;

        // use update or submit contribution
        if ($scope.activeCorrection.editing) {
            var correctionId = $scope.activeCorrection.original.id;
            contributionService.updateContribution("corrections", correctionId, correctionObj).then(function() {
                $scope.$emit('modalSuccessMessage', 'Correction updated successfully.');
                // update original correction object and discard copy
                $scope.updateCorrection();
                $scope.discardCorrection();
            }, function(response) {
                var params = {label: 'Error updating Correction', response: response};
                $scope.$emit('modalErrorMessage', params);
            });
        } else {
            contributionService.submitContribution("corrections", correctionObj).then(function(correction) {
                $scope.$emit('modalSuccessMessage', 'Correction submitted successfully.');
               $scope.target.corrections.unshift(correction);
                $scope.discardCorrection();
            }, function(response) {
                var params = {label: 'Error submitting Correction', response: response};
                $scope.$emit('modalErrorMessage', params);
            });
        }
    }
});
