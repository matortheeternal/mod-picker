app.controller('modAnalysisController', function($scope, $stateParams, $state, modService) {
    $scope.thisTab = $scope.findTab('Analysis');

    $scope.updatePlugin = function() {
        $scope.thisTab.params.plugin = $scope.mod.currentPlugin.id;
        $scope.refreshTab($scope.thisTab);
    };
    //update the params on the tab object
    $scope.thisTab.params = {
        plugin: $stateParams.plugin
    };

    // retrieve the analysis
    modService.retrieveModAnalysis($stateParams.modId).then(function(analysis) {
        $scope.mod.analysis = analysis;
        $scope.mod.plugins = analysis.plugins;
        $scope.mod.assets = analysis.assets;
        $scope.mod.nestedAssets = analysis.nestedAssets;

        // set current plugin
        if (analysis.plugins.length > 0) {
            var statePlugin = analysis.plugins.find(function(plugin) {
                return plugin.id === $stateParams.plugin;
            });
            //if the plugin defined in the params isn't part of this mod, then reload the tab with
            //the mod's first plugin selected
            if (!statePlugin) {
                $scope.thisTab.params.plugin = analysis.plugins[0].id;
                $scope.refreshTab($scope.thisTab);
            } else {
                $scope.mod.currentPlugin = statePlugin;
            }
        }
    }, function(response) {
        $scope.errors.analysis = response;
    });
});
