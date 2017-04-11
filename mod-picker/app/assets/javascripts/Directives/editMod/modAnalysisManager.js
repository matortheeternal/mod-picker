app.directive('modAnalysisManager', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modAnalysisManager.html',
        scope: false,
        controller: 'modAnalysisManagerController'
    }
});

app.controller('modAnalysisManagerController', function($scope, $rootScope, $timeout, pluginService, assetUtils, objectUtils) {
    // inherited variables
    $scope.currentGame = $rootScope.currentGame;

    $scope.changeAnalysisFile = function(event) {
        var input = event.target;
        if (input.files && input.files[0]) {
            $scope.loadingAnalysis = true;
            $timeout(function() {
                $scope.loadAnalysisFile(input.files[0]);
                input.value = "";
            });
        }
    };

    $scope.browseAnalysisFile = function() {
        document.getElementById('analysis-input').click();
    };

    $scope.clearAnalysis = function() {
        if ($scope.mod.analysis) {
            delete $scope.mod.analysis;
        } else {
            $scope.mod.mod_options.forEach(function(modOption) {
                modOption._destroy = true;
            });
        }
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

    $scope.destroyUnusedOldOptions = function() {
        if (!$scope.mod.analysis || !$scope.mod.mod_options) return;
        var newOptions = $scope.mod.analysis.mod_options;
        var newOptionIds = newOptions.map(function(option) {
            return option.id;
        });
        $scope.mod.mod_options.forEach(function(oldOption) {
            if (newOptionIds.indexOf(oldOption.id) == -1) {
                oldOption._destroy = true;
            } else if (oldOption.hasOwnProperty('_destroy')) {
                delete oldOption._destroy;
            }
        });
    };

    $scope.getBaseName = function(option) {
        var regex = new RegExp('(v?[0-9\.\_]+)?(\-[0-9]([0-9a-z\-]+))?\.(7z|rar|zip)', 'i');
        option.base_name = option.name.replace(regex, '');
    };

    $scope.optionNamesMatch = function(option, oldOption) {
        return option.name === oldOption.name && !oldOption._destroy;
    };

    $scope.optionSizesMatch = function(option, oldOption) {
        return option.size == oldOption.size && !oldOption._destroy;
    };

    $scope.findOldOption = function(oldOptions, option) {
        return oldOptions.find(function(oldOption) {
            return $scope.optionNamesMatch(option, oldOption) &&
                $scope.optionSizesMatch(option, oldOption);
        }) || oldOptions.find(function(oldOption) {
            return $scope.optionNamesMatch(option, oldOption);
        }) || oldOptions.find(function(oldOption) {
            return $scope.optionSizesMatch(option, oldOption);
        });
    };

    $scope.loadExistingOption = function(option) {
        var oldOptions = $scope.mod.mod_options;
        if (!oldOptions) return;
        var oldOption = $scope.findOldOption(oldOptions, option);
        if (oldOption) {
            option.id = oldOption.id;
            option.display_name = angular.copy(oldOption.display_name);
        }
    };

    $scope.prepareModOption = function(option) {
        $scope.getBaseName(option);
        option.display_name = angular.copy(option.base_name);
        if (option.assets && option.assets.length) {
            option.nestedAssets = assetUtils.getNestedAssets(option.assets);
        }
        $scope.loadExistingOption(option);
    };

    $scope.parseError = function(e) {
        console.log("Error parsing mod analysis: " + e);
        var params = {
            type: "error",
            text: "There was an error parsing the mod analysis.  Make sure the analysis was produced with the latest version of Mod Analyzer."
        };
        $scope.$emit('customMessage', params);
    };

    $scope.parseAnalysis = function(fixedJson) {
        var analysis = JSON.parse(fixedJson);
        analysis.mod_options.forEach($scope.prepareModOption);
        $scope.$applyAsync(function() {
            $scope.mod.analysis = analysis;
            $scope.loadingAnalysis = false;
            $scope.getRequirementsFromAnalysis();
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
                var json = event.target.result;
                var fixedJson = objectUtils.remapProperties(json, jsonMap);
                $scope.parseAnalysis(fixedJson);
                $scope.destroyUnusedOldOptions();
            } catch (e) {
                $scope.parseError(e);
            }
        };
        fileReader.readAsText(file);
    };

    $scope.$on('destroyUnusedOldOptions', function() {
        $scope.destroyUnusedOldOptions();
    });

    $scope.$on('removeModOption', function(event, option) {
        $scope.removeOption(option);
    });
});