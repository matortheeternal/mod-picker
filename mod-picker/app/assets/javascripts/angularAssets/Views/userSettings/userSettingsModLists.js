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
});