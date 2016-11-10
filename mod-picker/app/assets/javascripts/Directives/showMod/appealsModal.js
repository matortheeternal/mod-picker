app.directive('appealsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/appealsModal.html',
        controller: 'appealsModalController',
        scope: false
    };
});

app.controller('appealsModalController', function($scope, contributionService, contributionFactory, eventHandlerFactory, formUtils) {
    // inherited functions
    $scope.unfocusAppealsModal = formUtils.unfocusModal($scope.toggleStatusModal);

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    // compute agree percentage helper
    $scope.computeAgreePercentage = function(appeal) {
        return (appeal.agree_count / ((appeal.agree_count + appeal.disagree_count) || 1)) * 100;
    };

    // update the markdown editor
    $scope.updateEditor = function() {
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    // start a new appeal
    $scope.startNewAppeal = function() {
        var statuses = ["good", "outdated", "unstable"];
        statuses.splice(statuses.indexOf($scope.mod.status) || 0, 1);
        // TODO: Remove statuses that already have open appeals as well
        $scope.activeAppeal = {
            text_body: contributionFactory.getDefaultTextBody("Appeal"),
            mod_status: statuses[0]
        };

        // update editor
        $scope.updateEditor(true);
    };

    // edit an existing appeal
    $scope.editAppeal = function(appeal) {
        appeal.editing = true;
        $scope.activeAppeal = {
            text_body: appeal.text_body.slice(0),
            mod_status: appeal.mod_status,
            original: appeal,
            editing: true
        };

        // update validation, update the markdown editor
        $scope.validateAppeal();
        $scope.updateEditor(true);
    };

    $scope.retrieveAppealComments = function(page) {
        var options = {
            sort: {
                column: 'submitted',
                direction: 'DESC'
            },
            page: page || 1
        };
        contributionService.retrieveComments('corrections', $scope.appeal.id, options, $scope.pages.appeal_comments).then(function(data) {
            $scope.appeal.comments = data;
            delete $scope.appeal.retrieving_comments;
        }, function(response) {
            $scope.errors.appeal_comments = response;
        });
    };

    $scope.startNewComment = function() {
        $scope.$broadcast('startNewComment');
    };

    $scope.showAppeal = function(appeal) {
        $scope.appeal = appeal;
        if (!appeal.comments && !appeal.retrieving_comments) {
            appeal.retrieving_comments = true;
            $scope.retrieveAppealComments();
        }
    };

    $scope.showIndex = function() {
        // NOTE: It's important that we're not deleting this, as that would remove
        // the appeal from the index view as well, which is not desireable
        $scope.appeal = null;
    };

    $scope.validateAppeal = function() {
        var sanitized_text = contributionService.removePrompts($scope.activeAppeal.text_body);
        $scope.activeAppeal.valid = sanitized_text.length > 256;
    };

    // discard a new appeal object or stop editing an existing one
    $scope.discardAppeal = function() {
        if ($scope.activeAppeal.editing) {
            $scope.activeAppeal.original.editing = false;
            $scope.activeAppeal = null;
        } else {
            delete $scope.activeAppeal;
        }
    };

    // update an appeal locally
    $scope.updateAppeal = function() {
        var originalAppeal = $scope.activeAppeal.original;
        var updatedAppeal = $scope.activeAppeal;
        // update the values on the original appeal
        originalAppeal.text_body = updatedAppeal.text_body.slice(0);
        originalAppeal.mod_status = updatedAppeal.mod_status;
    };

    // save an appeal
    $scope.saveAppeal = function() {
        // return if the appeal is invalid
        if (!$scope.activeAppeal.valid) {
            return;
        }

        // submit the appeal
        var sanitized_text = contributionService.removePrompts($scope.activeAppeal.text_body);
        var appealObj = {
            correction: {
                game_id: $scope.mod.game_id,
                correctable_id: $scope.mod.id,
                correctable_type: "Mod",
                text_body: sanitized_text,
                mod_status: $scope.activeAppeal.mod_status
            }
        };
        $scope.activeAppeal.submitting = true;

        // use update or submit contribution
        if ($scope.activeAppeal.editing) {
            var appealId = $scope.activeAppeal.original.id;
            contributionService.updateContribution("corrections", appealId, appealObj).then(function() {
                $scope.$emit("modalSuccessMessage", "Appeal updated successfully.");
                // update original appeal object and discard copy
                $scope.updateAppeal();
                $scope.discardAppeal();
            }, function(response) {
                var params = {label: 'Error updating Appeal', response: response};
                $scope.$emit('modalErrorMessage', params);
            });
        } else {
            contributionService.submitContribution("corrections", appealObj).then(function(appeal) {
                $scope.$emit("modalSuccessMessage", "Appeal submitted successfully.");
                $scope.mod.corrections.unshift(appeal);
                $scope.discardAppeal();
            }, function(response) {
                var params = {label: 'Error submitting Appeal', response: response};
                $scope.$emit('modalErrorMessage', params);
            });
        }
    }
});
