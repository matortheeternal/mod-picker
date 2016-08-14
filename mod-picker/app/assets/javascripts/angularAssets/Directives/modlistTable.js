app.directive('modListTable', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modListTable.html',
        controller: 'modListTableController',
        scope: {
            modLists: '=',
            title: '@'
        }
    };
});

app.controller('modListTableController', function($scope, $state, modListService) {
    $scope.clone = function(modList) {
        console.log('Clone Mod list: "' + modList.name + '"');
        $scope.errors = [];
        modListService.cloneModlist(modList).then(function(data) {
            // TODO: verify that this parameter is correct
            $state.go('base.mod-list', {modListId: data.id});
        }, function(response) {
            var params = { label: "Failed to clone mod list", response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.delete = function(modList) {
        console.log('Delete Mod modList: "' + modList.name + '"');
        $scope.errors = [];
        modListService.deleteModlist(modList).then(function(data) {
            var modLists = $scope.user.mod_lists;
            var index = modLists.indexOf(modList);
            modLists.splice(index, 1);
            if (modList.is_collection) {
                index = $scope.collections.indexOf(modList);
                $scope.collections.splice(index, 1);
            } else {
                index = $scope.modLists.indexOf(modList);
                $scope.modLists.splice(index, 1);
            }
            $scope.$apply();
        }, function(response) {
            var params = { label: "Failed to delete mod list", response: response };
            $scope.$emit('errorMessage', params);
        });
    };
});
