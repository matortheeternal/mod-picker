app.directive('importedPlugins', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/importedPlugins.html',
        controller: 'importedPluginsController',
        scope: {
            importedPlugins: '=?'
        }
    };
});

app.controller('importedPluginsController', function($scope, pluginService, columnsFactory, actionsFactory, tableUtils) {
    // inherit scope attributes
    angular.inherit($scope, 'importedPlugins');

    // initialize variables
    $scope.columns = columnsFactory.pluginImportColumns();
    $scope.actions = actionsFactory.modListImportActions();
    $scope.sort = {
        column: '',
        direction: 'ASC'
    };

    // expose service functions
    $scope.searchPlugins = pluginService.searchPlugins;
    $scope.sortColumn = tableUtils.sortColumn;
    $scope.resolve = tableUtils.resolve($scope);

    // local functions
    $scope.remove = function(item) {
        var index = $scope.importedPlugins.indexOf(item);
        if (index > -1) $scope.importedPlugins.splice(index, 1);
        if (!$scope.importedPlugins.length) delete $scope.importedPlugins;
    };

    $scope.addMatchingPlugins = function(sourceData, matchData) {
        var importedPlugins = matchData.map(function(matchData, index) {
            return {
                filename: sourceData[index].plugin_filename,
                mod_name: matchData && matchData.mod.name,
                mod_id: matchData && matchData.mod.id,
                id: matchData && matchData.id,
                custom: !matchData
            };
        });
        $scope.$applyAsync(function() {
            $scope.loading = false;
            $scope.importedPlugins = ($scope.importedPlugins || []).concat(importedPlugins);
        });
    };

    $scope.errorFindingPlugins = function(response) {
        $scope.loading = false;
        var params = { text: "Error finding matching plugins", response: response };
        $scope.$emit('modalErrorMessage', params);
    };

    $scope.findMatchingPlugins = function(sourceData) {
        $scope.loading = true;
        pluginService.searchPluginsBatch(sourceData).then(function(matchData) {
            $scope.addMatchingPlugins(sourceData, matchData);
            $scope.$parent.$broadcast('addMatchingPluginMods', matchData);
        }, $scope.errorFindingPlugins);
    };

    $scope.$on('findMatchingPlugins', function(e, sourceData) {
        $scope.findMatchingPlugins(sourceData);
    });
});