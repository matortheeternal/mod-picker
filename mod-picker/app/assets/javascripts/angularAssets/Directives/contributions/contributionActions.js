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
            hasHistory: '=?'   // default undefined
        }
    };
});

app.controller('contributionActionsController', function($scope, $timeout, contributionService, contributionFactory, userTitleService) {
    // permissions helper variables
    var user = $scope.$parent.$parent.currentUser;
    var rep = user.reputation.overall;
    var isAdmin = user && user.role === 'admin';
    var isModerator = user && user.role === 'moderator';
    var isSubmitter = user && user.id === $scope.target.submitted_by;
    // set up permissions
    $scope.canReport = user || false;
    $scope.canAgree = $scope.agreeable && $scope.isOpen && ((rep > 40) || isAdmin || isModerator);
    $scope.canCorrect = (rep > 40) || isAdmin || isModerator;
    $scope.canEdit = isAdmin || isModerator || isSubmitter;
    $scope.canApprove = $scope.approveable && (isAdmin || isModerator);
    $scope.canHide = isAdmin || isModerator;

    // correctable should have a default value of true
    $scope.correctable = angular.isDefined($scope.correctable) ? $scope.correctable : true;
    // approveable should have a default value of true
    $scope.approveable = angular.isDefined($scope.approveable) ? $scope.approveable : true;

    // we get the model for the route and label
    $scope.model = contributionFactory.getModel($scope.modelName);

    // this is a direct link to the contribution to be displayed in the get link modal
    $scope.shareLink = window.location.href + '/' + $scope.model.route + '/' + $scope.target.id;
    // this is the report object
    $scope.report = {};

    // retrieving object for tracking what we're retrieving
    $scope.retrieving = {};
    // pages object for tracking pagination
    $scope.pages = {
        correction_comments: {}
    };
    // display errors object for tracking display errors
    $scope.displayErrors = {};

    // compute whether or not the target is open if it is agreeable
    if ($scope.agreeable) {
        $scope.isOpen = $scope.target.status === 'open';
    }

    // compute agree percentage helper
    $scope.computeAgreePercentage = function(appeal) {
        return (appeal.agree_count / ((appeal.agree_count + appeal.disagree_count) || 1)) * 100;
    };

    $scope.toggleShareModal = function(visible) {
        $scope.showShareModal = visible;
    };

    $scope.toggleReportModal = function(visible) {
        $scope.showReportModal = visible;
    };

    $scope.toggleCorrectionsModal = function(visible) {
        $scope.showCorrectionsModal = visible;
        if (!$scope.target.corrections && !$scope.retrieving.corrections) {
            $scope.retrieveCorrections();
        }
    };

    $scope.toggleHistoryModal = function(visible) {
        $scope.showHistoryModal = visible;
        if (!$scope.target.history && !$scope.retrieving.history) {
            $scope.retrieveHistory();
        }
    };

    $scope.retrieveCorrections = function() {
        $scope.retrieving.corrections = true;
        contributionService.retrieveCorrections($scope.model.route, $scope.target.id).then(function(data) {
            contributionService.associateAgreementMarks(data.corrections, data.agreement_marks);
            // TODO: This will work automatically after the service refactor
            //userTitleService.associateTitles(data.corrections, $scope.userTitles);
            $scope.target.corrections = data.corrections;
        });
    };

    $scope.retrieveHistory = function() {
        $scope.retrieving.history = true;
        contributionService.retrieveHistory($scope.model.route, $scope.target.id).then(function(data) {
            // TODO: This will work automatically after the service refactor
            //userTitleService.associateTitles(data, $scope.userTitles);
            $scope.target.history = data;
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
        if ($scope.target.helpful == helpful) {
            contributionService.helpfulMark($scope.model.route, $scope.target.id).then(function(data) {
                if (data.status == "ok") {
                    delete $scope.target.helpful;
                    $scope.updateHelpfulCounter(helpful, false);
                }
            });
        } else {
            contributionService.helpfulMark($scope.model.route, $scope.target.id, helpful).then(function(data) {
                if (data.status == "ok") {
                    if ($scope.target.helpful == !helpful) {
                        $scope.updateHelpfulCounter(!helpful, false);
                    }
                    $scope.target.helpful = helpful;
                    $scope.updateHelpfulCounter(helpful, true);
                }
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
        if ($scope.target.agree == agree) {
            contributionService.agreementMark($scope.model.route, $scope.target.id).then(function(data) {
                if (data.status == "ok") {
                    delete $scope.target.agree;
                    $scope.updateAgreeCounter(agree, false);
                }
            });
        } else {
            contributionService.agreementMark($scope.model.route, $scope.target.id, agree).then(function(data) {
                if (data.status == "ok") {
                    if ($scope.target.agree == !agree) {
                        $scope.updateAgreeCounter(!agree, false);
                    }
                    $scope.target.agree = agree;
                    $scope.updateAgreeCounter(agree, true);
                }
            });
        }
    };

    $scope.approve = function(approved) {
        contributionService.approve($scope.model.route, $scope.target.id, approved).then(function(data) {
            if (data.status == "ok") {
                $scope.target.approved = approved;
            }
        });
    };

    $scope.hide = function(hidden) {
        contributionService.hide($scope.model.route, $scope.target.id, hidden).then(function(data) {
            if (data.status == "ok") {
                $scope.target.hidden = hidden;
            }
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

});
