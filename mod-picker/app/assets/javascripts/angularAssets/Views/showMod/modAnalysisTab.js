app.controller('modAnalysisController', function($scope, $stateParams, $state, modService) {
    $scope.thisTab = $scope.findTab('Analysis');
    // verify we can access this tab
    if (!$scope.thisTab) {
        // if we can't access this tab, redirect to the first tab we can access and
        // stop doing stuff in this controller
        $scope.redirectToFirstTab();
        return;
    }

    //update the params on the tab object
    $scope.thisTab.params = {
        plugin: $stateParams.plugin
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
            if (analysis.plugins.length > 0) {
                var statePlugin = analysis.plugins.find(function(plugin) {
                    return plugin.id === $stateParams.plugin;
                });
                $scope.mod.currentPlugin = statePlugin || analysis.plugins[0];
                $scope.switchPlugin();
            }
        }, function(response) {
            $scope.errors.analysis = response;
        });
    };

    // retrieve analysis if we don't have them and aren't currently retrieving it
    if (!$scope.mod.analysis && !$scope.retrieving.analysis) {
        $scope.retrieveAnalysis();
    } else {
        $scope.switchPlugin();
    }
});