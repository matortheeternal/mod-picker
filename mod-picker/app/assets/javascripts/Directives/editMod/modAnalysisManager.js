app.directive('modAnalysisManager', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modAnalysisManager.html',
        scope: false,
        controller: 'modAnalysisManagerController'
    }
});

app.controller('modAnalysisManagerController', function($scope, $rootScope, pluginService, objectUtils, assetUtils) {
    // inherited variables
    $scope.currentGame = $rootScope.currentGame;

    $scope.changeAnalysisFile = function(event) {
        var input = event.target;
        if (input.files && input.files[0]) {
            $scope.loadAnalysisFile(input.files[0]);
            input.value = "";
        }
    };

    $scope.browseAnalysisFile = function() {
        document.getElementById('analysis-input').click();
    };

    $scope.removeOption = function(option) {
        var modOptions = $scope.mod.analysis.mod_options;
        var index = modOptions.indexOf(option);
        modOptions.splice(index, 1);
        if (modOptions.length == 0) {
            delete $scope.mod.analysis;
        }
    };

    $scope.addRequirementFromPlugin = function(filename) {
        pluginService.searchPlugins(filename).then(function(plugins) {
            var plugin = plugins.find(function(plugin) {
                return plugin.filename === filename;
            });
            if (plugin) {
                var match = $scope.mod.requirements.find(function(requirement) {
                    return requirement.required_id == plugin.mod.id;
                });
                if (!match) {
                    $scope.mod.requirements.push({
                        required_id: plugin.mod.id,
                        name: plugin.mod.name
                    });
                }
            }
        });
    };

    $scope.isGameMaster = function(master) {
        return master.filename === $scope.currentGame.esm_name ||
            master.filename === "Update.esm";
    };

    $scope.getRequirementsFromAnalysis = function() {
        // build list of masters
        var masters = [];
        var defaultPlugins = [];
        $scope.mod.analysis.mod_options.forEach(function(option) {
            if (option.default) {
                defaultPlugins.unite(option.plugins);
            }
        });
        defaultPlugins.forEach(function(plugin) {
            plugin.master_plugins.forEach(function(master) {
                var index = masters.indexOf(master.filename);
                if (index == -1 && !$scope.isGameMaster(master)) {
                    masters.push(master.filename);
                }
            });
        });
        // load requirements from masters
        masters.forEach(function(filename) {
            $scope.addRequirementFromPlugin(filename);
        });
    };

    $scope.loadAnalysisFile = function(file) {
        var fileReader = new FileReader();
        var jsonMap = {
            plugin_record_groups: 'plugin_record_groups_attributes',
            plugin_errors: 'plugin_errors_attributes',
            overrides: 'overrides_attributes'
        };
        fileReader.onload = function(event) {
            try {
                var fixedJson = objectUtils.remapProperties(event.target.result, jsonMap);
                var analysis = JSON.parse(fixedJson);
                analysis.mod_options.forEach(function(option) {
                    option.nestedAssets = assetUtils.getNestedAssets(option.assets);
                    option.display_name = angular.copy(option.name);
                });
                $scope.mod.analysis = analysis;
                $scope.getRequirementsFromAnalysis();
            } catch (e) {
                console.log("Error parsing mod analysis: " + e);
                var params = {
                    type: "error",
                    text: "There was an error parsing the mod analysis.  Make sure the analysis was produced with the latest version of Mod Analyzer."
                };
                $scope.$emit('customMessage', params)
            }
        };
        fileReader.readAsText(file);
    };
});