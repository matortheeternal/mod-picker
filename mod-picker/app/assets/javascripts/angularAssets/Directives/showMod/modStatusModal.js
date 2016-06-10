app.directive('modStatusModal', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/modStatusModal.html',
        controller: 'modStatusModalController',
        scope: false
    };
});

app.controller('modStatusModalController', function ($scope, contributionService) {
    // compute agree percentage helper
    $scope.computeAgreePercentage = function(appeal) {
        return (appeal.agree_count / ((appeal.agree_count + appeal.disagree_count) || 1)) * 100;
    };

    // start a new appeal
    $scope.startNewAppeal = function() {
        var statuses = ["good", "outdated", "dangerous"];
        statuses.splice(statuses.indexOf($scope.mod.status) || 0, 1);
        $scope.activeAppeal = {
            title: "",
            text_body: "", // TODO: Get template from the contributionFactory
            mod_status: statuses[0]
        };

        // update editor
        $scope.updateEditor(true);
    };

    // edit an existing appeal
    $scope.editAppeal = function(appeal) {
        appeal.editing = true;
        $scope.activeAppeal = {
            title: appeal.title.slice(0),
            text_body: appeal.text_body.slice(0),
            mod_status: appeal.mod_status,
            original: appeal,
            editing: true
        };

        // update validation, update the markdown editor
        $scope.validateAppeal();
        $scope.updateEditor(true);
    };

    $scope.showAppeal = function(appeal) {
        $scope.statusModal.appeal = appeal;
    };

    $scope.showIndex = function() {
        // NOTE: It's important that we're not deleting this, as that would remove
        // the appeal from the index view as well, which is not desireable
        $scope.statusModal.appeal = null;
    };

    $scope.validateAppeal = function() {
        $scope.activeAppeal.valid = ($scope.activeAppeal.title.length > 4) &&
            ($scope.activeAppeal.text_body.length > 256);
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
    $scope.updateAppeal = function () {
        var originalAppeal = $scope.activeAppeal.original;
        var updatedAppeal = $scope.activeAppeal;
        // update the values on the original appeal
        originalAppeal.title = updatedAppeal.title.slice(0);
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
        var appealObj = {
            correction: {
                game_id: $scope.mod.game_id,
                correctable_id: $scope.mod.id,
                correctable_type: "Mod",
                title: $scope.activeAppeal.title,
                text_body: $scope.activeAppeal.text_body,
                mod_status: $scope.activeAppeal.mod_status
            }
        };
        $scope.activeAppeal.submitting = true;

        // use update or submit contribution
        if ($scope.activeAppeal.editing) {
            var appealId = $scope.activeAppeal.original.id;
            contributionService.updateContribution("corrections", appealId, appealObj).then(function(data) {
                if (data.status === "ok") {
                    $scope.statusModal.submitMessage = "Appeal updated successfully!";
                    $scope.statusModal.showSuccess = true;

                    // update original appeal object and discard copy
                    $scope.updateAppeal();
                    $scope.discardAppeal();
                }
            });
        } else {
            contributionService.submitContribution("corrections", appealObj).then(function(data) {
                if (data.status === "ok") {
                    $scope.statusModal.submitMessage = "Appeal submitted successfully!";
                    $scope.statusModal.showSuccess = true;
                    // TODO: push the appeal onto the $scope.mod.corrections array
                    $scope.discardAppeal();
                }
            });
        }
    }
});
