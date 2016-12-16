app.directive('modListImportModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/modListImportModal.html',
        controller: 'modListImportModalController',
        scope: false
    };
});

app.controller('modListImportModalController', function($scope, $rootScope, $state, modListService, eventHandlerFactory, formUtils, importUtils) {
    // inherited variables
    $scope.gameName = $rootScope.currentGame.nexus_name;

    // inherited functions
    $scope.unfocusImportModal = formUtils.unfocusModal($scope.toggleImportModal);
    eventHandlerFactory.buildModalMessageHandlers($scope);

    // initialize variables
    $scope.importTypes = importUtils.importTypes;
    $scope.selectedImportType = $scope.importTypes[0];
    var fileInputIds = ['mod-list-xml-input', 'mod-list-txt-input', 'load-order-txt-input'];
    $scope.imported = {
        mods: null,
        plugins: null
    };

    // local functions
    $scope.clearImportedData = function() {
        fileInputIds.forEach(function(id) {
            document.getElementById(id).val('');
        });
        $scope.$broadcast('clearImportedData');
    };

    $scope.selectImportType = function(importType) {
        $scope.selectedImportType.selected = false;
        $scope.selectedImportType = importType;
        importType.selected = true;
        $scope.clearImportedData();
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
            $scope.$broadcast('findMatchingMods', modData);
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

    $scope.import = function() {
        var modListId = $scope.mod_list.id, imported = $scope.imported;
        $scope.startSubmission("Importing mod list...");
        modListService.import(modListId, imported.mods || [], imported.plugins || []).then(function() {
            $scope.submissionSuccess('Successfully imported mod list.  Reloading...', []);
            $state.reload();
        }, function(response) {
            $scope.submissionError("There were errors importing the mod list.", response);
        });
    };
});
