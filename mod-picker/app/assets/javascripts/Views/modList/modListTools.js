app.controller('modListToolsController', function($scope, $rootScope, $state, $stateParams, $timeout, categories, categoryService, modListService, modService, listUtils, columnsFactory, actionsFactory, listMetaFactory) {
    // INITIALIZE VARIABLES
    $scope.columns = columnsFactory.modListModColumns();
    $scope.columnGroups = columnsFactory.modListModColumnGroups();
    $scope.actions = actionsFactory.modListToolActions();

    // SHARED FUNCTIONS
    $scope.searchTools = modService.searchModListTools;
    listMetaFactory.buildModelFunctions($scope, 'tool', 'mod', 'name', 'Custom Tool');

    // MODAL HANDLING
    $scope.showDetailsModal = false;
    $scope.detailsItem = {};

    $scope.toggleDetailsModal = function(visible, item) {
        $scope.$emit('toggleModal', visible);
        $scope.showDetailsModal = visible;
        $scope.detailsItem = item;
    };

    // DATA LOADING
    $scope.buildToolsModel = function() {
        listUtils.buildModel($scope.model, $scope.mod_list, 'tools');
    };

    $scope.loadToolData = function(data) {
        categoryService.associateCategories($scope.categories, data.tools);
        $scope.required.tools = data.required_tools;
        $scope.loadAndTrack(data, 'tools');
        $scope.loadAndTrack(data, 'custom_tools');
        $scope.loadGroups(data.groups);
        $scope.buildToolsModel();
        $timeout(function() {
            $scope.$broadcast('initializeModules');
        }, 100);
    };

    $scope.retrieveTools = function() {
        modListService.retrieveModListTools($scope.mod_list.id).then(function(data) {
            $scope.loadToolData(data);
            $scope.toolsReady = true;
        }, function(response) {
            $scope.errors.tools = response;
        });
    };

    // retrieve tools when the state is first loaded
    $scope.retrieveTools();

    // CUSTOM CALLBACKS
    $scope.addCustomToolCallback = function(options) {
        options.item.is_utility = true;
    };

    // event triggers
    $scope.$on('removeMod', function(event, modId) {
        var foundTool = $scope.findTool(modId);
        if (foundTool) $scope.removeTool(foundTool);
    });
    $scope.$on('removeItem', function(event, modListTool) {
        $scope.removeTool(modListTool);
    });
    $scope.$on('rebuildModels', $scope.buildToolsModel);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.mod_list.tools);
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.mod_list.tools);
    });
    $scope.$on('toggleDetailsModal', function(event, options) {
        $scope.toggleDetailsModal(options.visible, options.item);
    });
});