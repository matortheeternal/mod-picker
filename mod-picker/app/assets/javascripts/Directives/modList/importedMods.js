app.directive('importedMods', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/importedMods.html',
        controller: 'importedModsController',
        scope: {
            importedMods: '=?'
        }
    };
});

app.controller('importedModsController', function($scope, modService, columnsFactory, actionsFactory, tableUtils) {
    // initialize variables
    $scope.columns = columnsFactory.modImportColumns();
    $scope.actions = actionsFactory.modListImportActions();
    $scope.sort = {
        column: '',
        direction: 'ASC'
    };

    // expose service functions
    $scope.searchMods = modService.searchMods;
    $scope.sortColumn = tableUtils.sortColumn;
    $scope.resolve = tableUtils.resolve($scope);

    // local functions
    $scope.remove = function(item) {
        var index = $scope.importedMods.indexOf(item);
        if (index > -1) $scope.importedMods.splice(index, 1);
        if (!$scope.importedMods.length) delete $scope.importedMods;
    };

    $scope.getSourceData = function(item) {
        return {
            nexus_info_id: item.nexus_info_id,
            mod_name: item.mod_name,
            plugins: item.plugin_filename ? [item.plugin_filename] : []
        };
    };

    $scope.combineSourceData = function(targetMod, sourceMod) {
        var targetModData = targetMod.sourceData;
        var sourceModData = sourceMod.sourceData;
        ["nexus_info_id", "mod_name"].forEach(function(key) {
            targetModData[key] = sourceModData[key] || targetModData[key];
        });
        targetModData.plugins = targetModData.plugins.concat(sourceModData.plugins);
    };

    $scope.concatImportedMods = function(importedMods) {
        if (!$scope.importedMods) $scope.importedMods = [];
        importedMods.forEach(function(mod) {
            if (!mod.id) {
                $scope.importedMods.push(mod);
            } else {
                var foundMod = $scope.importedMods.find(function(existingMod) {
                    return existingMod.id == mod.id;
                });
                foundMod ? $scope.combineSourceData(foundMod, mod) : $scope.importedMods.push(mod);
            }
        });
    };

    $scope.addMatchingMods = function(sourceData, matchData) {
        var importedMods = matchData.map(function(matchData, index) {
            return {
                sourceData: $scope.getSourceData(sourceData[index]),
                id: matchData && matchData.id,
                name: matchData ? matchData.name : sourceData[index].mod_name,
                custom: !matchData
            };
        });
        $scope.$applyAsync(function() {
            $scope.loading = false;
            $scope.concatImportedMods(importedMods);
        });
    };

    $scope.addMatchingPluginMods = function(matchData) {
        var importedMods = [];
        matchData.forEach(function(matchData) {
            if (!matchData || !matchData.hasOwnProperty('mod')) return;
            importedMods.push({
                sourceData: {
                    plugins: [matchData.filename]
                },
                id: matchData.mod.id,
                name: matchData.mod.name
            });
        });
        $scope.$applyAsync(function() {
            $scope.loading = false;
            $scope.concatImportedMods(importedMods);
        });
    };

    $scope.errorFindingMods = function(response) {
        $scope.loading = false;
        var params = { text: "Error finding matching mods", response: response };
        $scope.$emit('modalErrorMessage', params);
    };

    $scope.findMatchingMods = function(sourceData) {
        $scope.loading = true;
        modService.searchModsBatch(sourceData).then(function(matchData) {
            $scope.addMatchingMods(sourceData, matchData)
        }, $scope.errorFindingMods);
    };

    $scope.$on('addMatchingPluginMods', function(e, matchData) {
        $scope.addMatchingPluginMods(matchData);
    });

    $scope.$on('findMatchingMods', function(e, sourceData) {
        $scope.findMatchingMods(sourceData);
    });

    $scope.$on('clearImportedData', function(e) {
        delete $scope.importedMods;
    });
});