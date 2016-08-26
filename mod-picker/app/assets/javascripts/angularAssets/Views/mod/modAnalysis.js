app.controller('modAnalysisController', function($scope, $stateParams, $state, modService) {
    $scope.switchPlugin = function() {
        $state.go($state.current.name, {plugin: $scope.mod.currentPlugin.id});
    };

    $scope.retrieveAnalysis = function(pluginId) {
        // retrieve the analysis
        modService.retrieveModAnalysis($stateParams.modId).then(function(analysis) {
            $scope.mod.analysis = analysis;
            $scope.mod.plugins = analysis.plugins;
            $scope.mod.assets = analysis.assets;
            $scope.mod.nestedAssets = analysis.nestedAssets;

            // set current plugin
            if (analysis.plugins.length > 0) {
                var statePlugin = analysis.plugins.find(function(plugin) {
                    return plugin.id === pluginId;
                });
                // if the plugin defined in the params isn't part of this mod, then set the currentPlugin to the first plugin of this mod and update the url parameter
                if (!statePlugin) {
                    var firstPlugin = analysis.plugins[0];
                    $scope.mod.currentPlugin = firstPlugin;
                    $state.go($state.current.name, {plugin: firstPlugin.id});
                } else {
                    $scope.mod.currentPlugin = statePlugin;
                }
            }

        }, function(response) {
            $scope.errors.analysis = response;
        });
    };

    //retrieve the data when the state is first loaded
    $scope.retrieveAnalysis($stateParams.plugin);

    $scope.showMore = function(master) {
        master.max_overrides += 1000;
    };

    $scope.showLess = function(master) {
        master.max_overrides -= 1000;
    };
});
