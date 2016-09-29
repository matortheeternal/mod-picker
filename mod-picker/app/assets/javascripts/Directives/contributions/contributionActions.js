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
    $scope.permissions = $rootScope.permissions;

    // default scope attributes
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
    $scope.shareLink = window.location.href + '/' + $scope.target.id;
    $scope.model = contributionFactory.getModel($scope.modelName);

    // compute whether or not the target is open if it is agreeable
    if ($scope.agreeable) {
        $scope.isOpen = $scope.target.status === 'open';
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
        contributionService.retrieveCorrections($scope.model.route, $scope.target.id).then(function(data) {
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
        contributionService.retrieveHistory($scope.model.route, $scope.target.id).then(function(data) {
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
            contributionService.helpfulMark($scope.model.route, $scope.target.id).then(function() {
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
            contributionService.helpfulMark($scope.model.route, $scope.target.id, helpful).then(function() {
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
            contributionService.agreementMark($scope.model.route, $scope.target.id).then(function() {
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
            contributionService.agreementMark($scope.model.route, $scope.target.id, agree).then(function() {
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
        contributionService.approve($scope.model.route, $scope.target.id, approved).then(function() {
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
        contributionService.hide($scope.model.route, $scope.target.id, hidden).then(function() {
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

    $scope.blurDropdown = function() {
        // we have to use a timeout for hiding the dropdown because
        // otherwise we would hide it before the click event on a result
        // went through
        $timeout(function() {
            $scope.showDropdown = false;
        }, 100);
    };

    $scope.setPermissions = function() {
        // permissions helper variables
        var user = $scope.currentUser;
        var canModerate = $scope.permissions.canModerate;
        var isSubmitter = user && user.id == $scope.target.submitted_by;
        var isCorrector = user && user.id == $scope.target.corrector_id;
        var isLocked = $scope.target.corrector_id;
        // set up permissions
        $scope.canReport = user || false;
        $scope.canAgree = $scope.agreeable && $scope.isOpen && $scope.permissions.canAgree;
        $scope.canCorrect = $scope.permissions.canCorrect;
        $scope.canEdit = $scope.edit && (canModerate || isCorrector || isSubmitter && !isLocked);
        $scope.canApprove = $scope.approveable && canModerate;
        $scope.canHide = canModerate;
    };

    // watch user so if we get the user object after rendering actions
    // we can re-render them correctly per the user's permissions
    $scope.$watch('currentUser', $scope.setPermissions, true);
});