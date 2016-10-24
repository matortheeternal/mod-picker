app.directive('contributionActions', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/contributionActions.html',
        controller: 'contributionActionsController',
        scope: {
            target: '=',
            index: '=',
            modelName: '@',
            correctable: '=?', // default true
            approveable: '=?', // default true
            agreeable: '=?',   // default undefined
            edit: '=?',        // default undefined
            hasHistory: '=?',  // default undefined
            eventPrefix: '=?'  // default ''
        }
    };
});

app.controller('contributionActionsController', function($scope, $rootScope, $timeout, contributionService, contributionFactory) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // default scope attributes
    angular.inherit($scope, 'showMarks');
    angular.default($scope, 'correctable', true);
    angular.default($scope, 'approveable', true);

    // initialize local variables
    $scope.report = {
        reportable_id: $scope.target.id,
        reportable_type: $scope.modelName
    };
    $scope.retrieving = {};
    $scope.pages = {
        correction_comments: {}
    };
    $scope.errors = {};
    $scope.errorEvent = $scope.eventPrefix ? $scope.eventPrefix + 'ErrorMessage' : 'errorMessage';
    $scope.modelObj = contributionFactory.getModel($scope.modelName);

    $scope.modNote = {};

    // determine share url based on the content type
    $scope.buildShareLink = function() {
        var modTarget, modId, targetTab, targetId, baseUrl = location.href.replace(location.hash, "");
        if ($scope.modelName === "Correction") {
            var correctableType = $scope.target.correctable_type;
            if (correctableType === "Mod") {
                modId = $scope.target.correctable_id;
                $scope.shareLink = baseUrl + '#/mod/' + modId + '/appeals';
            } else {
                var correctable = $scope.target.correctable;
                var correctableModel = contributionFactory.getModel(correctableType);
                modTarget = correctable.mod || correctable.first_mod;
                modId = modTarget.id;
                targetTab = correctableModel.tab;
                targetId = $scope.target.correctable_id;
                $scope.shareLink = baseUrl + '#/mod/' + modId + '/' + targetTab + '/' + targetId + '/corrections';
            }
        } else {
            modId = $scope.target.mod_id || $scope.target.first_mod_id;
            targetTab = $scope.modelObj.tab;
            targetId = $scope.target.id;
            $scope.shareLink = baseUrl + '#/mod/' + modId + '/' + targetTab + '/' + targetId;
        }
    };

    // compute whether or not the target is open if it is agreeable
    if ($scope.agreeable) {
        $scope.isOpen = $scope.target.status === 'open';
    } else {
        $scope.buildShareLink();
    }

    // compute agree percentage helper
    $scope.computeAgreePercentage = function(appeal) {
        return (appeal.agree_count / ((appeal.agree_count + appeal.disagree_count) || 1)) * 100;
    };

    $scope.toggleShareModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showShareModal = visible;
    };

    $scope.toggleReportModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showReportModal = visible;
    };

    $scope.toggleCorrectionsModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showCorrectionsModal = visible;
        if (!$scope.target.corrections && !$scope.retrieving.corrections) {
            $scope.retrieveCorrections();
        }
    };

    $scope.toggleHistoryModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showHistoryModal = visible;
        if (!$scope.target.history && !$scope.retrieving.history) {
            $scope.retrieveHistory();
        }
    };

    $scope.retrieveCorrections = function() {
        $scope.retrieving.corrections = true;
        contributionService.retrieveCorrections($scope.modelObj.route, $scope.target.id).then(function(data) {
            $scope.retrieving.corrections = false;
            $scope.target.corrections = data;
        }, function(response) {
            $scope.errors.corrections = response;
            $timeout(function() {
                $scope.retrieving.corrections = false;
            }, 15000);
        });
    };

    $scope.retrieveHistory = function() {
        $scope.retrieving.history = true;
        contributionService.retrieveHistory($scope.modelObj.route, $scope.target.id).then(function(data) {
            $scope.retrieving.history = false;
            $scope.target.history = data;
        }, function(response) {
            $scope.errors.history = response;
            $timeout(function() {
                $scope.retrieving.history = false;
            }, 15000);
        });
    };

    $scope.updateHelpfulCounter = function(helpful, increment) {
        var value = increment ? 1 : -1;
        if (helpful) {
            $scope.target.helpful_count += value;
        } else {
            $scope.target.not_helpful_count += value;
        }
    };

    $scope.helpfulMark = function(helpful) {
        var helpfulStr = helpful ? 'helpful' : 'not helpful';
        if ($scope.target.helpful == helpful) {
            contributionService.helpfulMark($scope.modelObj.route, $scope.target.id).then(function() {
                delete $scope.target.helpful;
                $scope.updateHelpfulCounter(helpful, false);
            }, function(response) {
                var params = {
                    label: 'Error removing ' + helpfulStr + ' mark',
                    response: response
                };
                $scope.$emit($scope.errorEvent, params);
            });
        } else {
            contributionService.helpfulMark($scope.modelObj.route, $scope.target.id, helpful).then(function() {
                if ($scope.target.helpful == !helpful) {
                    $scope.updateHelpfulCounter(!helpful, false);
                }
                $scope.target.helpful = helpful;
                $scope.updateHelpfulCounter(helpful, true);
            }, function(response) {
                var params = {
                    label: 'Error creating ' + helpfulStr + ' mark',
                    response: response
                };
                $scope.$emit($scope.errorEvent, params);
            });
        }
    };

    $scope.updateAgreeCounter = function(agree, increment) {
        var value = increment ? 1 : -1;
        if (agree) {
            $scope.target.agree_count += value;
        } else {
            $scope.target.disagree_count += value;
        }
    };

    $scope.agreementMark = function(agree) {
        var agreeStr = agree ? 'agreement' : 'disagreement';
        if ($scope.target.agree == agree) {
            contributionService.agreementMark($scope.modelObj.route, $scope.target.id).then(function() {
                delete $scope.target.agree;
                $scope.updateAgreeCounter(agree, false);
            }, function(response) {
                var params = {
                    label: 'Error removing ' + agreeStr + ' mark',
                    response: response
                };
                $scope.$emit($scope.errorEvent, params);
            });
        } else {
            contributionService.agreementMark($scope.modelObj.route, $scope.target.id, agree).then(function() {
                if ($scope.target.agree == !agree) {
                    $scope.updateAgreeCounter(!agree, false);
                }
                $scope.target.agree = agree;
                $scope.updateAgreeCounter(agree, true);
            }, function(response) {
                var params = {
                    label: 'Error creating ' + agreeStr + ' mark',
                    response: response
                };
                $scope.$emit($scope.errorEvent, params);
            });
        }
    };

    $scope.approve = function(approved) {
        contributionService.approve($scope.modelObj.route, $scope.target.id, approved).then(function() {
            $scope.target.approved = approved;
        }, function(response) {
            var approveStr = approved ? 'approving' : 'unapproving';
            var params = {
                label: 'Error ' + approveStr + ' contribution',
                response: response
            };
            $scope.$emit($scope.errorEvent, params);
        });
    };

    $scope.hide = function(hidden) {
        contributionService.hide($scope.modelObj.route, $scope.target.id, hidden).then(function() {
            $scope.target.hidden = hidden;
        }, function(response) {
            var approveStr = hidden ? 'hiding' : 'unhiding';
            var params = {
                label: 'Error ' + approveStr + ' contribution',
                response: response
            };
            $scope.$emit($scope.errorEvent, params);
        });
    };

    $scope.addNote = function() {
        $scope.modNote.addingNote = true;
        $scope.modNote.message = "";
    };

    $scope.saveNote = function() {
        $scope.target.moderator_message = $scope.modNote.message;
        contributionService.updateContribution($scope.modelObj.route, $scope.target.id, $scope.target).then(function() {
            $scope.$emit("successMessage", "Moderator Note added successfully.");
            delete $scope.modNote.addingNote;
            delete $scope.modNote.message;
        }, function(response) {
            var params = { label: 'Error adding Moderator Note', response: response };
            $scope.$emit('errorMessage', params);
            $scope.target.moderator_message = null;
        });
    };

    $scope.discardNote = function() {
        $scope.modNote.message = null;
        delete $scope.modNote.addingNote;
    };

    $scope.blurDropdown = function() {
        // we have to use a timeout for hiding the dropdown because
        // otherwise we would hide it before the click event on a result
        // went through
        $timeout(function() {
            $scope.showDropdown = false;
        }, 250);
    };

    $scope.setPermissions = function() {
        // permissions helper variables
        var user = $scope.currentUser;
        if (!user) return;
        var canModerate = $scope.permissions.canModerate;
        var isSubmitter = user && user.id == $scope.target.submitted_by;
        var isCorrector = user && user.id == $scope.target.corrector_id;
        var isLocked = $scope.target.corrector_id;
        // set up permissions
        $scope.isSubmitter = isSubmitter;
        $scope.canReport = $scope.permissions.canReport && !isSubmitter;
        $scope.canAgree = $scope.agreeable && $scope.isOpen && $scope.permissions.canAgree;
        $scope.canCorrect = $scope.permissions.canCorrect;
        $scope.canEdit = $scope.edit && (canModerate || isCorrector || isSubmitter && !isLocked);
        $scope.canApprove = $scope.approveable && canModerate;
        $scope.canHide = canModerate;
        $scope.canAddNote = canModerate;
    };

    // watch user so if we get the user object after rendering actions
    // we can re-render them correctly per the user's permissions
    $scope.$watch('currentUser', $scope.setPermissions, true);
});
