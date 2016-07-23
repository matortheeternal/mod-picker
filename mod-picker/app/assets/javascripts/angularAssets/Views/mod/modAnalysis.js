app.controller('modAnalysisController', function($scope, $stateParams, $state, contributionService) {
    // verify we can access this tab
    $scope.currentTab = $scope.findTab('Analysis');
    if (!$scope.currentTab) {
        // if we can't access this tab, redirect to the first tab we can access and
        // stop doing stuff in this controller
        $state.go('base.mod.' + $scope.tabs[0].name, {
            modId: $stateParams.modId
        });
        return;
    }

    // PLUGIN SWITCHING LOGIC
    $scope.switchPlugin = function() {
        // transition to new url state
        var params = {
            modId: $stateParams.modId,
            plugin: $scope.mod.currentPlugin.id
        };
        $state.transitionTo('base.mod.Analysis', params, { notify: false });
    };

    // BASE RETRIEVAL LOGIC
    $scope.retrieveAnalysis = function() {
        $scope.retrieving.analysis = true;

        // retrieve the analysis
        contributionService.retrieveModAnalysis($stateParams.modId).then(function(analysis) {
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