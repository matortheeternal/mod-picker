app.directive('editTagModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/editTagModal.html',
        controller: 'editTagModalController',
        scope: false
    }
});

app.controller('editTagModalController', function($scope, $q, $timeout, tagService, formUtils, eventHandlerFactory) {
    // inherited functions
    $scope.unfocusTagModal = formUtils.unfocusModal($scope.toggleTagModal);

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    $scope.searchTags = function(s) {
        var action = $q.defer();
        $timeout(function() {
            var str = s.toLowerCase();
            var matches = tagService.getTagMatches($scope.allTags, str);
            tagService.sortTagMatches(str, matches);
            action.resolve(matches);
        }, 100);
        return action.promise;
    };

    $scope.saveTag = function() {
        tagService.updateTag($scope.activeTag).then(function() {
            $scope.$emit('modalSuccessMessage', 'Updated tag "' + $scope.activeTag.text + '" successfully');
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

    $scope.replaceTag = function() {
        var oldTagId = $scope.originalTag.id, newTagId = $scope.activeTag.id;
        tagService.replaceTag(oldTagId, newTagId).then(function() {
            $scope.$emit('modalSuccessMessage', 'Replaced tag "' + $scope.originalTag.text + '" successfully');
            $scope.$applyAsync(function() {
                $scope.originalTag.hidden = true;
                $scope.originalTag.mods_count = 0;
                $scope.originalTag.mod_lists_count = 0;
            });
        }, function(response) {
            var params = {
                text: 'Error replacing tag: '+$scope.originalTag.text,
                response: response
            };
            $scope.$emit('modalErrorMessage', params);
        });
    };

    // tag retrieval
    if (!$scope.allTags) {
        tagService.retrieveAllTags().then(function(data) {
            $scope.allTags = data;
        });
    }
});
