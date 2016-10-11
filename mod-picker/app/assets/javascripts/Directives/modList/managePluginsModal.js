app.directive('managePluginsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/managePluginsModal.html',
        controller: 'managePluginsModalController',
        scope: false
    };
});

app.controller('managePluginsModalController', function($scope, columnsFactory, actionsFactory) {
    // re-initialize plugins store active booleans to false
    $scope.plugins_store.forEach(function(plugin) {
        plugin.active = false;
    });

    // initialize variables for table-results
    $scope.columns = columnsFactory.modListPluginStoreColumns();
    $scope.columnGroups = columnsFactory.modListPluginStoreColumnGroups();
    // $scope.actions = actionsFactory.modListPluginActions();
    $scope.actions = actionsFactory.modListPluginStoreActions();

    // update plugins store active booleans based on plugins that are in the mod list
    $scope.mod_list.plugins.forEach(function(modListPlugin) {
        if (modListPlugin._destroy) return;

        var foundPlugin = $scope.plugins_store.find(function(plugin) {
            return plugin.id == modListPlugin.plugin.id;
        });
        if (foundPlugin) {
            foundPlugin.active = true;
        }
    });
});
