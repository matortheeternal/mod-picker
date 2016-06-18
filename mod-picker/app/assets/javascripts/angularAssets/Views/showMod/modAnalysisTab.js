app.controller('modAnalysisController', function($scope, $stateParams, $state, modService) {
    // set local variables
    $scope.currentTab = $scope.findTab('Analysis');

    // PLUGIN SWITCHING LOGIC
    $scope.switchPlugin = function(newPlugin) {
        $scope.currentPlugin = newPlugin;

        // transition to new url state
        var params = {
            modId: $stateParams.modId,
            plugin: newPlugin.id
        };
        $state.transitionTo('base.mod.Analysis', params, { notify: false });
    };

    // BASE RETRIEVAL LOGIC
    $scope.retrieveAnalysis = function() {
        $scope.retrieving.analysis = true;

        // retrieve the analysis
        modService.retrieveModAnalysis($stateParams.modId).then(function(analysis) {
            $scope.retrieving.analysis = false;
            $scope.mod.analysis = analysis;
            $scope.mod.plugins = analysis.plugins;
            $scope.mod.assets = analysis.assets;
            $scope.mod.nestedAssets = analysis.nestedAssets;

            // set current plugin
            var statePlugin = analysis.plugins.find(function(plugin) {
                return plugin.id === $stateParams.plugin;
            });
            $scope.switchPlugin(statePlugin || analysis.plugins[0]);
        }, function(response) {
            // TODO: Display error on view
        });
    };

    // retrieve analysis if we don't have them and aren't currently retrieving it
    if (!$scope.mod.analysis && !$scope.retrieving.analysis) {
        $scope.retrieveAnalysis();
    }
});