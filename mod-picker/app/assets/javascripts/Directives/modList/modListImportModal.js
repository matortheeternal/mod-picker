app.directive('modListImportModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modListImportModal.html',
        controller: 'modListImportModalController',
        scope: false
    };
});

app.controller('modListImportModalController', function($scope, $rootScope, modService, pluginService, eventHandlerFactory, columnsFactory, actionsFactory, sortUtils, tableUtils, formUtils, importUtils) {
    // inherited variables
    $scope.gameName = $rootScope.currentGame.nexus_name;

    // inherited functions
    $scope.unfocusImportModal = formUtils.unfocusModal($scope.toggleDetailsModal);
    $scope.searchMods = modService.searchMods;
    $scope.searchPlugins = pluginService.searchPlugins;

    // shared function setup
    eventHandlerFactory.buildModalMessageHandlers($scope);

    // initialize variables
    $scope.modColumns = columnsFactory.modImportColumns();
    $scope.pluginColumns = columnsFactory.pluginImportColumns();
    $scope.actions = actionsFactory.modListImportActions();
    $scope.loading = {};
    $scope.errors = {};

    $scope.sort = {
        column: '',
        direction: 'ASC'
    };

    $scope.importTypes = importUtils.importTypes;
    $scope.selectedImportType = $scope.importTypes[0];

    // expose service function to be usable in html
    $scope.sortColumn = tableUtils.sortColumn;

    // this function resolves a variable as a function if it is one,
    // else returns its value
    $scope.resolve = function(attribute, item, context) {
        if (typeof attribute === 'function') {
            return attribute($scope, item, context);
        } else {
            return attribute;
        }
    };

    $scope.selectImportType = function(importType) {
        // toggle selection
        $scope.selectedImportType.selected = false;
        $scope.selectedImportType = importType;
        importType.selected = true;
        delete $scope.importedMods;
    };

    $scope.getSourceData = function(mod) {
        return {
            nexus_info_id: mod.nexus_info_id,
            mod_name: mod.mod_name,
            plugin_filename: mod.plugin_filename
        };
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
            $scope.loading.importedMods = false;
            $scope.importedMods = ($scope.importedMods || []).concat(importedMods);
        });
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
            $scope.loading.importedPlugins = false;
            $scope.importedPlugins = ($scope.importedPlugins || []).concat(importedPlugins);
        });
    };

    $scope.errorFindingMods = function(response) {
        $scope.loading.importedMods = false;
        var params = { text: "Error finding matching mods", response: response };
        $scope.$emit('modalErrorMessage', params);
    };

    $scope.errorFindingPlugins = function(response) {
        $scope.loading.importedPlugins = false;
        var params = { text: "Error finding matching plugins", response: response };
        $scope.$emit('modalErrorMessage', params);
    };

    $scope.findMatchingMods = function(sourceData) {
        $scope.loading.importedMods = true;
        modService.searchModsBatch(sourceData).then(function(matchData) {
                $scope.addMatchingMods(sourceData, matchData)
        }, $scope.errorFindingMods);
    };

    $scope.findMatchingPlugins = function(sourceData) {
        $scope.loading.importedPlugins = true;
        pluginService.searchPluginsBatch(sourceData).then(function(matchData) {
            $scope.addMatchingPlugins(sourceData, matchData);
        }, $scope.errorFindingPlugins);
    };

    $scope.importPlugins = function(pluginData) {
        var importedPlugins = [];
        pluginData.forEach(function(plugin) {
            importedPlugins.push({
                filename: plugin.plugin_filename,
                mod_name: plugin.mod_name
            });
        });
        $scope.$applyAsync(function() {
            if (!$scope.importedPlugins) $scope.importedPlugins = [];
            $scope.importedPlugins = $scope.importedPlugins.concat(importedPlugins);
        });
    };

    $scope.removeImportedItem = function(item) {
        var importedItems = item.hasOwnProperty('filename') ? $scope.importedPlugins : $scope.importedMods;
        var index = importedItems.indexOf(item);
        if (index > -1) importedItems.splice(index, 1);
        if (!importedItems.length) {
            item.hasOwnProperty('filename') ? delete $scope.importedPlugins : delete $scope.importedMods;
        }
    };

    $scope.getFileText = function(event, callback) {
        var input = event.target;
        if (input.files && input.files[0]) {
            var file = input.files[0];
            var fileReader = new FileReader();
            fileReader.onload = function(event) {
                callback(event.target.result);
            };
            fileReader.readAsText(file);
        }
    };

    // HANDLE MODLIST.XML
    $scope.selectModListXml = function(event) {
        $scope.getFileText(event, function(text) {
            $scope.modListXml = text;
            var xmlDoc = importUtils.getXmlDoc($scope.modListXml);
            var modData = importUtils.getXmlModData(xmlDoc);
            $scope.findMatchingMods(modData);
        });
    };

    // HANDLE MODLIST.TXT
    $scope.selectModListTxt = function(event) {
        $scope.getFileText(event, function(text) {
            $scope.modListTxt = text;
            var modData = importUtils.getTxtModData($scope.modListTxt);
            $scope.findMatchingMods(modData);
        });
    };

    // HANDLE LOADORDER.TXT
    $scope.selectLoadOrderTxt = function(event) {
        $scope.getFileText(event, function(text) {
            $scope.loadOrderTxt = text;
            var pluginData = importUtils.getLoadOrderPluginData($scope.loadOrderTxt);
            $scope.findMatchingPlugins(pluginData);
        });
    };
});
