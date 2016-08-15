app.controller('userSettingsModListsController', function($scope, columnsFactory, actionsFactory, modListService) {
    // initialize variables
    $scope.actions = actionsFactory.userModListActions();
    $scope.columns = columnsFactory.modListColumns();
    $scope.columnGroups = columnsFactory.modListColumnGroups();

    // BASE RETRIEVAL LOGIC
    $scope.retrieveModLists = function() {
        var options = {
            filters: {
                submitter: $scope.user.username
            }
        };
        var pages = {};
        modListService.retrieveModLists(options, pages).then(function(data) {
            $scope.all_mod_lists = data.mod_lists;
            $scope.mod_lists = [];
            $scope.collections = [];
            data.mod_lists.forEach(function(item) {
                var model = item.is_collection ? $scope.collections : $scope.mod_lists;
                model.push(item);
            });
        }, function(response) {
            $scope.errors.mod_lists = response;
        });
    };

    //retrieve the mod lists when the state is first loaded
    $scope.retrieveModLists();

    // CREATE A NEW MOD LIST
    $scope.newModList = function(is_collection) {
        var mod_list = {
            game_id: window._current_game_id,
            name: $scope.currentUser.username + "'s Mod List",
            is_collection: is_collection,
            // TODO: Should have a default description set on the backend
            description: "A brand new mod list!"
        };
        var model = is_collection ? $scope.collections : $scope.mod_lists;
        var label = is_collection ? 'mod collection' : 'mod list';
        modListService.newModList(mod_list, false).then(function(data) {
            model.push(data.mod_list);
            $scope.$emit('successMessage', 'Created new ' + label + ' successfully.');
        }, function(response) {
            var params = {
                label: 'Error creating new ' + label,
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    }
});