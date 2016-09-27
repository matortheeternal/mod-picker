app.controller('userModListsController', function($scope, $rootScope, columnsFactory, actionsFactory, modListService, userService) {
    // initialize variables
    $scope.actions = actionsFactory.modListIndexActions();
    $scope.columns = columnsFactory.modListColumns();
    $scope.columnGroups = columnsFactory.modListColumnGroups();

    // BASE RETRIEVAL LOGIC
    $scope.retrieveModLists = function() {
        userService.retrieveUserModLists($scope.user.id).then(function(data) {
            // sort authored mod lists
            $scope.authored_mod_lists = [];
            $scope.authored_collections = [];
            data.authored.forEach(function(item) {
                var model = item.is_collection ?
                    $scope.authored_collections : $scope.authored_mod_lists;
                model.push(item);
            });

            // sort favorite mod lists
            $scope.favorite_mod_lists = [];
            $scope.favorite_collections = [];
            data.favorites.forEach(function(item) {
                var model = item.is_collection ?
                    $scope.favorite_collections : $scope.favorite_mod_lists;
                model.push(item);
            });
        }, function(response) {
            $scope.errors.mod_lists = response;
        });
    };

    //retrieve the mod lists when the state is first loaded
    $scope.retrieveModLists();

    // ACTION HANDLERS
    $scope.$on('cloneModList', function(event, modList) {
        // TODO
    });

    $scope.$on('deleteModList', function(event, modList) {
        modListService.hide(modList.id, true).then(function() {
            var model = modList.is_collection ? $scope.collections : $scope.mod_lists;
            var index = model.findIndex(function(item) {
                return item.id == modList.id;
            });
            model.splice(index, 1);
            if ($scope.activeModList && $scope.activeModList.id == modList.id) {
                $rootScope.activeModList = null;
            }
            $scope.$emit('successMessage', 'Mod list deleted successfully.');
        }, function(response) {
            var params = {
                label: 'Error deleting mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });

    $scope.$on('recoverModList', function(event, modList) {
        modListService.hide(modList.id, false).then(function() {
            modList.hidden = false;
            $scope.$emit('successMessage', 'Mod list recovered successfully.');
        }, function(response) {
            var params = {
                label: 'Error recovering mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });
});