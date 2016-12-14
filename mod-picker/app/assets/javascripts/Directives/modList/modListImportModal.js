app.directive('modListImportModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modListImportModal.html',
        controller: 'modListImportModalController',
        scope: false
    };
});

app.controller('modListImportModalController', function($scope, $rootScope, eventHandlerFactory, formUtils, importUtils) {
    // inherited variables
    $scope.gameName = $rootScope.currentGame.nexus_name;

    // inherited functions
    $scope.unfocusImportModal = formUtils.unfocusModal($scope.toggleDetailsModal);
    $scope.searchMods = modService.searchMods;
    $scope.searchPlugins = pluginService.searchPlugins;
    eventHandlerFactory.buildModalMessageHandlers($scope);

    // initialize variables
    $scope.importTypes = importUtils.importTypes;
    $scope.selectedImportType = $scope.importTypes[0];

    // local functions
    $scope.selectImportType = function(importType) {
        $scope.selectedImportType.selected = false;
        $scope.selectedImportType = importType;
        importType.selected = true;
        delete $scope.importedMods;
    };

    $scope.removeImportedItem = function(collection, item) {
        var index = collection.indexOf(item);
        if (index > -1) collection.splice(index, 1);
        if (!collection.length) {
            var isPlugin = item.hasOwnProperty('filename');
            isPlugin ? delete $scope.importedPlugins : delete $scope.importedMods;
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
            $scope.$broadcast('findMatchingMods', modData);
        });
    };

    // HANDLE LOADORDER.TXT
    $scope.selectLoadOrderTxt = function(event) {
        $scope.getFileText(event, function(text) {
            $scope.loadOrderTxt = text;
            var pluginData = importUtils.getLoadOrderPluginData($scope.loadOrderTxt);
            $scope.$broadcast('findMatchingPlugins', pluginData);
        });
    };
});
