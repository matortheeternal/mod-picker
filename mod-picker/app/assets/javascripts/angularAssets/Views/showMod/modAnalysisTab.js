app.controller('modAnalysisController', function($scope, $stateParams, analysis) {
    if (analysis) {
        $scope.mod.plugins = analysis.plugins;
        $scope.mod.assets = analysis.assets;
        $scope.mod.nestedAssets = analysis.nestedAssets;
        $scope.mod.currentPlugin = analysis.plugins[0];
    }

    $scope.currentTab = $scope.findTab('Analysis');
    $scope.currentParams = $scope.currentTab.params;
    $scope.currentParams.retrieve = false;
});