app.directive('editTagModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/editTagModal.html',
        controller: 'editTagModalController',
        scope: false
    }
});

app.controller('editTagModalController', function($scope, tagService, formUtils, eventHandlerFactory) {
    // inherited functions
    $scope.unfocusTagModal = formUtils.unfocusModal($scope.toggleTagModal);

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    $scope.saveTag = function() {
        tagService.updateTag($scope.activeTag).then(function() {
            $scope.$emit('modalSuccessMessage', 'Updated tag "' + $scope.activeTag.text + '"successfully');
            $scope.$applyAsync(function() {
                $scope.originalTag.text = $scope.activeTag.text;
            });
        }, function(response) {
            var params = {
                text: 'Error updating tag: '+$scope.activeTag.text,
                response: response
            };
            $scope.$emit('modalErrorMessage', params);
        });
    };
});
