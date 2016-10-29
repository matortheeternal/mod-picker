app.controller('modListAnalysisController', function($scope, modListService, pluginService) {
    $scope.buildConflictingOverrides = function() {
        $scope.analysis.maxOverrides = 1000;
        $scope.analysis.conflicting_overrides = [];
        $scope.analysis.load_order_overrides.forEach(function(override) {
            if (override.plugin_ids.length > 1) {
                $scope.analysis.conflicting_overrides.push(angular.copy(override));
            }
        });
        $scope.analysis.conflicting_overrides.forEach(function(override) {
            // associate master plugins
            override.master_plugin = $scope.analysis.load_order.find(function(item) {
                return override.fid >>> 24 == item.index;
            });
            // associate plugins and mods
            override.plugins = override.plugin_ids.map(function(plugin_id) {
                return pluginService.getLoadOrderPlugin($scope.analysis.load_order, plugin_id);
            });
            // sort plugins
            override.plugins.sort(function(firstPlugin, secondPlugin) {
                return firstPlugin.index - secondPlugin.index;
            });
        });
    };

    $scope.buildTotalPluginErrors = function() {
        $scope.analysis.totalPluginErrors = $scope.analysis.plugins.reduce(function(total, plugin) {
            return total + plugin.errors_count;
        }, 0);
    };

    $scope.retrieveAnalysis = function() {
        modListService.retrieveModListAnalysis($scope.mod_list.id).then(function(data) {
            $scope.analysis = data;
            $scope.buildConflictingOverrides();
            $scope.buildTotalPluginErrors();
            $scope.analysisReady = true;
        }, function(response) {
            $scope.errors.analysis = response;
        });
    };

    // retrieve analysis when the state is first loaded
    $scope.retrieveAnalysis();

    $scope.showMoreOverrides = function() {
        $scope.analysis.maxOverrides += 1000;
    };

    $scope.showLessOverrides = function() {
        if ($scope.analysis.maxOverrides > 1000) {
            $scope.analysis.maxOverrides -= 1000;
        }
    };
});