app.directive('curatorRequestActions', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/contributions/curatorRequestActions.html',
        controller: 'curatorRequestActionsController',
        scope: {
            target: '=',
            index: '='
        }
    };
});

app.controller('curatorRequestActionsController', function($scope, $rootScope, $timeout, contributionService, curatorRequestService, contributionFactory) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.permissions = angular.copy($rootScope.permissions);

    // initialize variables
    $scope.modelObj = contributionFactory.getModel('CuratorRequest');
    $scope.stateClasses = {
        open: '',
        approved: 'green-box',
        denied: 'red-box'
    };

    // change state of curator request
    $scope.changeState = function(newState) {
        curatorRequestService.changeState($scope.target.id, newState).then(function() {
            $scope.target.state = newState;
        }, function(response) {
            var params = {
                label: 'Error changing state to '+newState,
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    };

    // moderator note stuff
    $scope.editNote = function() {
        $scope.target.newModeratorNote = angular.copy($scope.target.moderator_message);
    };

    $scope.saveNote = function() {
        contributionService.updateModeratorNote($scope.modelObj.route, $scope.target.id, $scope.target.newModeratorNote).then(function() {
            $scope.$emit("successMessage", "Moderator Note added successfully.");
            $scope.target.moderator_message = $scope.target.newModeratorNote;
            delete $scope.target.newModeratorNote;
        }, function(response) {
            var params = { label: 'Error changing Moderator Note', response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.discardNote = function() {
        delete $scope.target.newModeratorNote;
    };

    $scope.removeModeratorMessage = function() {
        contributionService.removeModeratorNote($scope.modelObj.route, $scope.target.id).then(function() {
            $scope.$emit("successMessage", "Moderator Note removed successfully.");
            delete $scope.target.moderator_message;
        }, function(response) {
            var params = { label: 'Error removing Moderator Note', response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.focusDropdown = function() {
        $scope.showDropdown = true;
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
        var isSubmitter = user && user.id == $scope.target.submitter.id;
        // set up permissions
        $scope.canChangeState = canModerate;
        $scope.canEditNote = canModerate;
        $scope.canRemoveNote = canModerate;
        $scope.actionsAvailable = canModerate;
    };

    // watch user so if we get the user object after rendering actions
    // we can re-render them correctly per the user's permissions
    $scope.$watch('currentUser', $scope.setPermissions, true);
});
