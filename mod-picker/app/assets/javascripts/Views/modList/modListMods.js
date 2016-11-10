app.controller('modListModsController', function($scope, $rootScope, $timeout, $q, categoryService, modListService, modService, columnsFactory, actionsFactory, listMetaFactory, listUtils, sortUtils) {
    // INITIALIZE VARIABLES
    $scope.columns = columnsFactory.modListModColumns();
    $scope.columnGroups = columnsFactory.modListModColumnGroups();
    $scope.actions = actionsFactory.modListModActions();

    // SHARED FUNCTIONS
    $scope.searchMods = modService.searchModListMods;
    listMetaFactory.buildModelFunctions($scope, 'mod', 'mod', 'name', 'Custom Mod');
    listMetaFactory.buildSortFunctions($scope, 'install', 'mod', 'asset_files_count');

    // MODAL HANDLING
    $scope.showDetailsModal = false;
    $scope.detailsItem = {};

    $scope.toggleDetailsModal = function(visible, item) {
        $scope.$emit('toggleModal', visible);
        $scope.showDetailsModal = visible;
        $scope.detailsItem = item;
    };

    // DATA LOADING
    $scope.buildModsModel = function() {
        listUtils.buildModel($scope.model, $scope.mod_list, 'mods');
    };

    $scope.loadModData = function(data) {
        categoryService.associateCategories($scope.categories, data.mods);
        $scope.required.mods = data.required_mods;
        $scope.loadNotes(data, 'compatibility_notes', 'compatibility', 'CompatibilityNote');
        $scope.loadNotes(data, 'install_order_notes', 'install_order', 'InstallOrderNote');
        $scope.loadAndTrack(data, 'mods');
        $scope.loadAndTrack(data, 'custom_mods');
        $scope.loadGroups(data.groups);
        $scope.buildModsModel();
        $timeout(function() {
            $scope.$broadcast('initializeModules');
        }, 100);
    };

    $scope.retrieveMods = function() {
        modListService.retrieveModListMods($scope.mod_list.id).then(function(data) {
            $scope.loadModData(data);
            $scope.modsReady = true;
        }, function(response) {
            $scope.errors.mods = response;
        });
    };

    // retrieve mods when the state is first loaded
    $scope.retrieveMods();

    // HELPER FUNCTIONS
    $scope.recoverModOptions = function(modListMod) {
        modListMod.mod && modListMod.mod.mod_options.forEach(function(option) {
            var foundModOption = modListMod.mod_list_mod_options.find(function(ml_option) {
                return option.id == ml_option.id;
            });
            if (foundModOption) $rootScope.$broadcast('modOptionAdded', option);
        });
    };

    $scope.addDefaultModOptions = function(modListMod) {
        modListMod.mod.mod_options.forEach(function(option) {
            if (option.default) {
                option.active = true;
                modListMod.mod_list_mod_options.push({
                    mod_option_id: option.id
                });
                $rootScope.$broadcast('modOptionAdded', option);
            }
        });
    };

    $scope.removeActiveModOptions = function(modListMod) {
        modListMod.mod && modListMod.mod.mod_options.forEach(function(option) {
            if (option.active) $rootScope.$broadcast('modOptionRemoved', option.id);
        });
    };

    // CUSTOM CALLBACKS
    $scope.recoverModCallback = $scope.recoverModOptions;
    $scope.removeModCallback = $scope.removeActiveModOptions;

    // EVENT TRIGGERS
    $scope.$on('removeMod', function(event, modId) {
        var foundMod = $scope.findMod(modId);
        if (foundMod) $scope.removeMod(foundMod);
    });
    $scope.$on('modAdded', function(event, data) {
        $scope.addDefaultModOptions(data.mod_list_mod);
    });
    $scope.$on('modRemoved', function(event, modId) {
        $scope.removedModIds.push(modId);
    });
    $scope.$on('modRecovered', function(event, modId) {
        var index = $scope.removedModIds.indexOf(modId);
        if (index > -1) $scope.removedModIds.splice(index, 1);
    });
    $scope.$on('removeItem', function(event, modListMod) {
        $scope.removeMod(modListMod);
    });
    $scope.$on('rebuildModels', $scope.buildModsModel);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.mod_list.mods);
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.mod_list.mods);
        $scope.removedModIds = [];
    });
    $scope.$on('itemMoved', function() {
        $scope.$broadcast('modMoved');
    });
    $scope.$on('toggleDetailsModal', function(event, options) {
        $scope.toggleDetailsModal(options.visible, options.item);
    });
});