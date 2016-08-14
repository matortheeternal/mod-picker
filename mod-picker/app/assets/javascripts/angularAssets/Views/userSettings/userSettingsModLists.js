app.controller('userSettingsModListsController', function($scope, columnsFactory, actionsFactory) {
    $scope.actions = actionsFactory.userModListActions();
    $scope.columns = columnsFactory.modListColumns();
    $scope.columnGroups = columnsFactory.modListColumnGroups();
});