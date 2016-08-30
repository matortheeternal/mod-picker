app.controller('modAnalysisController', function($scope, $stateParams, $state, modService) {
    $scope.updateParams = function() {
        $state.go($state.current.name, {
            plugin: $scope.currentPlugin.id,
            options: $scope.optionIds.join(',')
        });
    };

    $scope.updateOptionPlugins = function() {
        $scope.availablePlugins = $scope.mod.plugins.filter(function(plugin) {
            return $scope.optionIds.indexOf(plugin.mod_option_id) > -1;
        });
    };

    $scope.updateOptionIds = function() {
        $scope.optionIds = [];
        $scope.mod.options.forEach(function(option) {
            if (option.active) $scope.optionIds.push(option.id);
        });
    };

    $scope.updateCurrentPlugin = function(pluginId) {
        if ($scope.availablePlugins.length) {
            var foundPlugin = $scope.availablePlugins.find(function (plugin) {
                return plugin.id == pluginId;
            });
            $scope.currentPlugin = foundPlugin || $scope.availablePlugins[0];
        } else {
            $scope.currentPlugin = null;
        }
    };

    $scope.toggleOption = function() {
        $scope.updateOptionIds();
        $scope.updateOptionPlugins();
        $scope.updateCurrentPlugin($stateParams.plugin);
        $scope.updateParams();
    };

    $scope.setCurrentSelection = function() {
        // set active options
        var optionIds = $stateParams.options ? $stateParams.options.split(',') : [];
        $scope.mod.options.forEach(function(option) {
            option.active = option.default || optionIds.indexOf(option.id) > -1;
        });

        // set up available plugins plugin
        $scope.toggleOption();
    };

    $scope.retrieveAnalysis = function() {
        // retrieve the analysis
        modService.retrieveModAnalysis($stateParams.modId).then(function(analysis) {
            $scope.mod.analysis = analysis;
            $scope.mod.options = analysis.mod_options;
            $scope.mod.plugins = analysis.plugins;
            $scope.mod.assets = analysis.assets;
            $scope.mod.nestedAssets = analysis.nestedAssets;

            // set current option and plugin
            $scope.setCurrentSelection();
        }, function(response) {
            $scope.errors.analysis = response;
        });
    };

    //retrieve the data when the state is first loaded
    $scope.retrieveAnalysis();

    $scope.showMore = function(master) {
        master.max_overrides += 1000;
    };

    $scope.showLess = function(master) {
        master.max_overrides -= 1000;
    };
});
