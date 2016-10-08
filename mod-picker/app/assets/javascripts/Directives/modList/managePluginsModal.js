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

    // initialize variables used for table-results
    $scope.actions = actionsFactory.modListPluginModalActions();
    $scope.columns = columnsFactory.modListPluginModalColumns();
    $scope.columnGroups = columnsFactory.modListPluginModalColumnGroups();

    // update plugins store active booleans based on plugins that are in the mod list
    $scope.model.plugins.forEach(function(modListPlugin) {
        var activeState = !modListPlugin._destroy;

        var foundPlugin = $scope.plugins_store.find(function(plugin) {
            return plugin.id == modListPlugin.plugin.id;
        });

        if(foundPlugin) {
            foundPlugin.active = activeState;
        }
    });

});
