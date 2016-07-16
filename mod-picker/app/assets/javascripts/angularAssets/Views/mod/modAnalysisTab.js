app.controller('modAnalysisController', function($scope, $stateParams, $state, contributionService) {
    $scope.thisTab = $scope.findTab('Analysis');

    //update the params on the tab object when the tab is navigated to directly
    $scope.thisTab.params = angular.copy($stateParams);
    $scope.params = $scope.thisTab.params;

    $scope.switchPlugin = function() {
        $scope.params.plugin = $scope.mod.currentPlugin.id;
        $scope.refreshTabParams($scope.thisTab);
    };

    $scope.retrieveAnalysis = function(pluginId) {
        // retrieve the analysis
        contributionService.retrieveModAnalysis($stateParams.modId).then(function(analysis) {
            $scope.mod.analysis = analysis;
            $scope.mod.plugins = analysis.plugins;
            $scope.mod.assets = analysis.assets;
            $scope.mod.nestedAssets = analysis.nestedAssets;

            // set current plugin
            if (analysis.plugins.length > 0) {
                var statePlugin = analysis.plugins.find(function(plugin) {
                    return plugin.id === $scope.params.plugin;
                });
                // if the plugin defined in the params isn't part of this mod, then set the currentPlugin to the first plugin of this mod and update the url parameter
                if (!statePlugin) {
                    $scope.mod.currentPlugin = analysis.plugins[0];
                    $scope.params.plugin = analysis.plugins[0].id;
                    $scope.refreshTabParams($scope.thisTab);
                } else {
                    $scope.mod.currentPlugin = statePlugin;
                }
            }

        }, function(response) {
            $scope.errors.analysis = response;
        });
    };

    //retrieve the data when the state is first loaded
    $scope.retrieveAnalysis($stateParams.page);
});
