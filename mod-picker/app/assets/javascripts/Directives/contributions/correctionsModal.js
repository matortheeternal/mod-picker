app.directive('correctionsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/correctionsModal.html',
        controller: 'correctionsModalController',
        scope: false
    };
});

app.controller('correctionsModalController', function($scope, contributionService, contributionFactory, eventHandlerFactory, formUtils) {
    // inherited functions
    $scope.unfocusCorrectionsModal = formUtils.unfocusModal($scope.toggleCorrectionsModal);

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    // compute agree percentage helper
    $scope.computeAgreePercentage = function(correction) {
        return (correction.agree_count / ((correction.agree_count + correction.disagree_count) || 1)) * 100;
    };

    // update the markdown editor
    $scope.updateEditor = function() {
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    // start a new correction
    $scope.startNewCorrection = function() {
        $scope.activeCorrection = {
            title: "",
            text_body: contributionFactory.getDefaultTextBody("Correction")
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
        var options = {
            sort: {
                column: 'submitted',
                direction: 'DESC'
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
        var sanitized_text = contributionService.removePrompts($scope.activeCorrection.text_body);
        var title = $scope.activeCorrection.title;
        $scope.activeCorrection.valid = title.length > 4 && sanitized_text.length > 256;
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
    $scope.updateCorrection = function() {
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
        var sanitized_text = contributionService.removePrompts($scope.activeCorrection.text_body);
        var correctionObj = {
            correction: {
                game_id: $scope.target.game_id,
                correctable_id: $scope.target.id,
                correctable_type: $scope.modelObj.name,
                title: sanitized_text,
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
